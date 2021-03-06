;; -*- lexical-binding: t -*-

(require 'cl-lib)

(require 'company)
(require 'lns-completion)

(defvar company-lns-buf-name "*company-lns-process*")
(defvar company-lns-buf-name-work "*company-lns-process-work*")


(defun lns-company-pick-type (txt)
  (when (string-match ": \\([a-zA-Z_0-9<>!]+\\)$" txt)
    (setq txt (match-string 1 txt)))
  txt
  )


(defun lns-company-exclude-type (txt)
  (when (string-match "\\(.*\\): [a-zA-Z_0-9<>!]+$" txt)
    (setq txt (match-string 1 txt)))
  txt
  )

(defun lns-company-make-candidate (candidate)
  (let* ((displayTxt (lns-candidate-get-displayTxt candidate))
	 (type (lns-candidate-get-type candidate)))
    (when displayTxt
      (cond
       ;; 型情報を補完文字列から除外
       ((or (equal type "Mtd")
	    (equal type "Fun")
	    (equal type "Var")
	    (equal type "Arg")
	    (equal type "Mbr"))
	(setq displayTxt (lns-company-exclude-type displayTxt)))
       )
      ;; getter アクセスの $ への変換
      (when (string-match "^get_\\([a-zA-Z_0-9<>!]+\\)()$" displayTxt)
	(setq displayTxt (format "$%s" (match-string 1 displayTxt))))
      (propertize displayTxt 'meta candidate))
    ))

(defvar lns-company-callback nil
  "補完処理中かどうかを示す。 nil 以外の場合は補完処理中。")
(defvar lns-company-req nil
  "補完処理中に再度補完要求があった場合、その補完要求をストックする。
ストックする補完要求は一つ。")

(defun lns-company-candidate-async (candidate-list err callback tmp-buf)
  "補完候補のピックアップ結果を元に処理する。

candidate-list: 補完候補
err: エラー情報
callback: comany の callbak
tmp-buf: 補完候補の生データを出力しているバッファ
"
  (cond
   (lns-company-req
    ;; 次の補完要求が来ている場合、補完処理をしなおす。
    (funcall callback '())
    (let ((buf (plist-get lns-company-req :buf)))
      (cond ((equal buf (current-buffer))
	     ;; バッファが変っていない場合は、候補をピックアップする
	     (let ((prefix (plist-get lns-company-req :prefix))
		   (workcallback (plist-get lns-company-req :callback)))
	       (run-at-time 0 nil (lambda ()
				    (company-lns--candidates
				     prefix workcallback))))
	     (setq lns-company-req nil))
	    (t
	     ;; バッファが変っている場合、ピックアップを中止する
	     (funcall (plist-get lns-company-req :callback) '())
	     (setq lns-company-req nil))))
    )
   (candidate-list
    ;; ピックアップできて、次の補完要求もない場合、
    ;; ピックアップ情報から company に表示する情報に変換し、callback に情報を渡す。
    (let (local-candidate-list)
      (setq local-candidate-list
	    (mapcar (lambda (X)
		      (lns-company-make-candidate (lns-json-val X :candidate)))
		    candidate-list))
      (funcall callback (delq nil local-candidate-list))
      )
    )
   (t
    ;; ピックアップできなかった場合
    (funcall callback '())))
  (with-current-buffer (get-buffer-create company-lns-buf-name)
    (erase-buffer)
    (insert (with-current-buffer tmp-buf
	      (buffer-string)))
    )
  (kill-buffer tmp-buf))

(defun company-lns--candidates (prefix callback)
  ;; 補完候補のリストを生成。補完候補は文字列。
  (cond (lns-company-callback
	 ;; 補完処理中の場合
	 (when lns-company-req
	   ;; 既に補完要求がストックされている場合は、
	   ;; ストックされている callback を nil でコールして
	   ;; ストックしている補完要求を終了させる。
	   (funcall (plist-get lns-company-req :callback) nil))
	 (setq lns-company-req
	       ;; 補完要求をストックする
	       (list :prefix prefix :callback callback :buf (current-buffer))))
	(t
	 (setq lns-company-callback callback)
	 (let ((tmp-buf (generate-new-buffer company-lns-buf-name-work)))
	   (condition-case err-info
	       ;; 補完実行中のエラー処理
	       ;; ピックアップした候補はバッファに出力するが、
	       ;; 非同期に補完候補をピックアップするので、
	       ;; バッファがそれぞれで必要なため generate-new-buffer で生成し、
	       ;; ピックアップ終了時に kill する。
	       (lns-completion-get-candidate-list
		(lambda (candidate-list err)
		  (setq lns-company-callback nil)
		  (lns-company-candidate-async candidate-list err callback tmp-buf))
		t tmp-buf)
	     ;; 全エラーをキャッチして投げなおす
	     (error (kill-buffer tmp-buf)
		    (funcall callback nil)
		    (setq lns-company-callback nil)
		    (signal (format "%s" (car err-info)) err-info))))))
    )

(defun company-lns--meta (candidate)
  ;; 補完候補リスト表示時の、補足説明文字列取得。 mini-buffer に表示される。
  "")
  ;; (format "This will use %s of %s"
  ;;         (get-text-property 0 'meta candidate)
  ;;         (substring-no-properties candidate)))

(defun company-lns--annotation (item)
  ;; company-lns--candidates で生成したリストのアイテムを表示する処理
  ;; candidate は、リストのアイテム
  (let* ((candidate (get-text-property 0 'meta item))
  	 (displayTxt (lns-candidate-get-displayTxt candidate)))
    (format ": %s" (lns-company-pick-type displayTxt))))


(defun company-lns (command &optional arg &rest ignored)
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'company-lns))
    ;; バージョンコマンドが動作しない場合は、
    ;; lunescript がインストールされていないと判断する。
    (init (when (not (eq (lns-command-sync "--version") 0))
	    (error "not found lns")))
    ;; 補完を開始する prefix の定義。 . で区切った場合に開始する。
    (prefix (and (eq major-mode 'lns-mode)
		 (company-grab-symbol-cons "\\." 1)))
    ;; 候補を生成する。 非同期。
    (candidates (cons :async
    		      (lambda (callback)
    			(company-lns--candidates arg callback))))
    ;; 候補のリストを表示する
    (annotation (company-lns--annotation arg))
    (meta (company-lns--meta arg))))

(add-to-list 'company-backends 'company-lns)

(add-hook 'lns-mode-hook 'company-mode)

;;(add-to-list 'company-safe-backends '(company-lns . "LuneScript"))

(provide 'lns-company-mode)
