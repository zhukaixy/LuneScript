--lune/base/Parser.lns
local moduleObj = {}
local function _lune_nilacc( val, fieldName, access, ... )
   if not val then
      return nil
   end
   if fieldName then
      local field = val[ fieldName ]
      if not field then
         return nil
      end
      if access == "item" then
         local typeId = type( field )
         if typeId == "table" then
            return field[ ... ]
         elseif typeId == "string" then
            return string.byte( field, ... )
         end
      end
      return field
   end
   if access == "item" then
      local typeId = type( val )
      if typeId == "table" then
         return val[ ... ]
      elseif typeId == "string" then
         return string.byte( val, ... )
      end
   end
   error( string.format( "illegal access -- %s", access ) )
end

local luaKeywordSet = {}

luaKeywordSet["let"] = true
luaKeywordSet["if"] = true
luaKeywordSet["else"] = true
luaKeywordSet["elseif"] = true
luaKeywordSet["while"] = true
luaKeywordSet["for"] = true
luaKeywordSet["in"] = true
luaKeywordSet["return"] = true
luaKeywordSet["break"] = true
luaKeywordSet["nil"] = true
luaKeywordSet["true"] = true
luaKeywordSet["false"] = true
luaKeywordSet["{"] = true
luaKeywordSet["}"] = true
luaKeywordSet["do"] = true
luaKeywordSet["require"] = true
luaKeywordSet["function"] = true
luaKeywordSet["then"] = true
luaKeywordSet["until"] = true
local function isLuaKeyword( txt )
  return luaKeywordSet[txt]
end
moduleObj.isLuaKeyword = isLuaKeyword
local function createReserveInfo( luaMode )
  local keywordSet = {}
  
  local typeSet = {}
  
  local builtInSet = {}
  
  builtInSet["require"] = true
  for key, val in pairs( luaKeywordSet ) do
    if not builtInSet[key] then
      keywordSet[key] = true
    end
  end
  if not luaMode then
    keywordSet["null"] = true
    keywordSet["let"] = true
    keywordSet["mut"] = true
    keywordSet["pub"] = true
    keywordSet["pro"] = true
    keywordSet["pri"] = true
    keywordSet["fn"] = true
    keywordSet["each"] = true
    keywordSet["form"] = true
    keywordSet["class"] = true
    builtInSet["super"] = true
    keywordSet["static"] = true
    keywordSet["advertise"] = true
    keywordSet["import"] = true
    keywordSet["new"] = true
    keywordSet["!"] = true
    keywordSet["unwrap"] = true
    keywordSet["sync"] = true
    typeSet["int"] = true
    typeSet["real"] = true
    typeSet["stem"] = true
    typeSet["str"] = true
    typeSet["Map"] = true
    typeSet["bool"] = true
  end
  local multiCharDelimitMap = {}
  
  multiCharDelimitMap["="] = {"=="}
  multiCharDelimitMap["~"] = {"~="}
  multiCharDelimitMap["<"] = {"<="}
  multiCharDelimitMap[">"] = {">="}
  if not luaMode then
    multiCharDelimitMap["["] = {"[@"}
    multiCharDelimitMap["$"] = {"$[", "$."}
    multiCharDelimitMap["$."] = {"$.$"}
    multiCharDelimitMap["."] = {"..", ".$"}
    multiCharDelimitMap[".."] = {"..."}
    multiCharDelimitMap[","] = {",,"}
    multiCharDelimitMap[",,"] = {",,,"}
    multiCharDelimitMap[",,,"] = {",,,,"}
    multiCharDelimitMap["@"] = {"@@"}
    multiCharDelimitMap["@@"] = {"@@?"}
  else 
    multiCharDelimitMap["."] = {".."}
  end
  return keywordSet, typeSet, builtInSet, multiCharDelimitMap
end

local Stream = {}
moduleObj.Stream = Stream
-- none
function Stream.new(  )
  local obj = {}
  setmetatable( obj, { __index = Stream } )
  if obj.__init then
    obj:__init(  )
  end        
  return obj 
 end         
function Stream:__init(  ) 
            
end
do
  end

local TxtStream = {}
setmetatable( TxtStream, { __index = Stream } )
moduleObj.TxtStream = TxtStream
function TxtStream.new( txt )
  local obj = {}
  setmetatable( obj, { __index = TxtStream } )
  if obj.__init then obj:__init( txt ); end
return obj
end
function TxtStream:__init(txt) 
  self.txt = txt
  self.start = 1
  if not txt then
    error( "txt is nil" )
  end
  self.eof = false
end
function TxtStream:read( mode )
  if self.eof then
    return nil
  end
  local index = self.txt:find( "\n", self.start, true )
  
  if index then
    local txt = self.txt:sub( self.start, index - 1 )
    
    self.start = index + 1
    return txt
  end
  self.eof = true
  return self.txt:sub( self.start )
end
do
  end

local Position = {}
moduleObj.Position = Position
function Position.new( lineNo, column )
  local obj = {}
  setmetatable( obj, { __index = Position } )
  if obj.__init then
    obj:__init( lineNo, column )
  end        
  return obj 
 end         
function Position:__init( lineNo, column ) 
            
self.lineNo = lineNo
  self.column = column
  end
do
  end

local Token = {}
moduleObj.Token = Token
function Token.new( kind, txt, pos, commentList )
  local obj = {}
  setmetatable( obj, { __index = Token } )
  if obj.__init then obj:__init( kind, txt, pos, commentList ); end
return obj
end
function Token:__init(kind, txt, pos, commentList) 
  self.kind = kind
  self.txt = txt
  self.pos = pos
  self.commentList = commentList or {}
end
function Token:set_commentList( commentList )
  self.commentList = commentList
end
function Token:get_commentList()
  return self.commentList
end
do
  end

local Parser = {}
moduleObj.Parser = Parser
-- none
-- none
function Parser.new(  )
  local obj = {}
  setmetatable( obj, { __index = Parser } )
  if obj.__init then
    obj:__init(  )
  end        
  return obj 
 end         
function Parser:__init(  ) 
            
end
do
  end

local WrapParser = {}
setmetatable( WrapParser, { __index = Parser } )
moduleObj.WrapParser = WrapParser
function WrapParser:getToken(  )
  local token = self.parser:getToken(  )
  
  return token
end
function WrapParser:getStreamName(  )
  return self.name
end
function WrapParser.new( parser, name )
  local obj = {}
  setmetatable( obj, { __index = WrapParser } )
  if obj.__init then
    obj:__init( parser, name )
  end        
  return obj 
 end         
function WrapParser:__init( parser, name ) 
            
self.parser = parser
  self.name = name
  end
do
  end

local StreamParser = {}
setmetatable( StreamParser, { __index = Parser } )
moduleObj.StreamParser = StreamParser
function StreamParser.new( stream, name, luaMode )
  local obj = {}
  setmetatable( obj, { __index = StreamParser } )
  if obj.__init then obj:__init( stream, name, luaMode ); end
return obj
end
function StreamParser:__init(stream, name, luaMode) 
  self.stream = stream
  self.streamName = name
  self.lineNo = 0
  self.pos = 1
  self.lineTokenList = {}
  local keywordSet, typeSet, builtInSet, multiCharDelimitMap = createReserveInfo( luaMode )
  
  self.keywordSet = keywordSet
  self.typeSet = typeSet
  self.builtInSet = builtInSet
  self.multiCharDelimitMap = multiCharDelimitMap
end
function StreamParser:getStreamName(  )
  return self.streamName
end
function StreamParser.create( path, luaMode )
  local stream = io.open( path, "r" )
  
      if  not stream then
        local _stream = stream
        
        return nil
      end
    
  return StreamParser.new(stream, path, luaMode or string.find( path, "%.lua$" ))
end
do
  end


local kind2Txt = {}

local TokenKind = {}
moduleObj.TokenKind = TokenKind
function TokenKind.new(  )
  local obj = {}
  setmetatable( obj, { __index = TokenKind } )
  if obj.__init then obj:__init(  ); end
return obj
end
function TokenKind:__init() 
  self.Cmnt = 1
  self.Str = 2
  self.Int = 3
  self.Real = 4
  self.Char = 5
  self.Symb = 6
  self.Dlmt = 7
  self.Kywd = 8
  self.Ope = 9
  self.Type = 10
  self.Eof = 11
  -- none
  
end
do
  end

kind2Txt[1] = 'Cmnt'
local kindCmnt = 1

moduleObj.kindCmnt = kindCmnt

kind2Txt[2] = 'Str'
local kindStr = 2

moduleObj.kindStr = kindStr

kind2Txt[3] = 'Int'
local kindInt = 3

moduleObj.kindInt = kindInt

kind2Txt[4] = 'Real'
local kindReal = 4

moduleObj.kindReal = kindReal

kind2Txt[5] = 'Char'
local kindChar = 5

moduleObj.kindChar = kindChar

kind2Txt[6] = 'Symb'
local kindSymb = 6

moduleObj.kindSymb = kindSymb

kind2Txt[7] = 'Dlmt'
local kindDlmt = 7

moduleObj.kindDlmt = kindDlmt

kind2Txt[8] = 'Kywd'
local kindKywd = 8

moduleObj.kindKywd = kindKywd

kind2Txt[9] = 'Ope'
local kindOpe = 9

moduleObj.kindOpe = kindOpe

kind2Txt[10] = 'Type'
local kindType = 10

moduleObj.kindType = kindType

kind2Txt[11] = 'Eof'
local kindEof = 11

moduleObj.kindEof = kindEof

-- none


local kind = TokenKind.new()

moduleObj.kind = kind

local noneToken = Token.new(kindEof, "", Position.new(0, 0), {})

moduleObj.noneToken = noneToken

local quotedCharSet = {}

quotedCharSet['a'] = true
quotedCharSet['b'] = true
quotedCharSet['f'] = true
quotedCharSet['n'] = true
quotedCharSet['r'] = true
quotedCharSet['t'] = true
quotedCharSet['v'] = true
quotedCharSet['\\'] = true
quotedCharSet['"'] = true
quotedCharSet["'"] = true
local op2Set = {}

op2Set['+'] = true
op2Set['-'] = true
op2Set['*'] = true
op2Set['/'] = true
op2Set['//'] = true
op2Set['^'] = true
op2Set['%'] = true
op2Set['&'] = true
op2Set['~'] = true
op2Set['|'] = true
op2Set['>>'] = true
op2Set['<<'] = true
op2Set['..'] = true
op2Set['<'] = true
op2Set['<='] = true
op2Set['>'] = true
op2Set['>='] = true
op2Set['=='] = true
op2Set['~='] = true
op2Set['and'] = true
op2Set['or'] = true
op2Set['@'] = true
op2Set['='] = true
local op1Set = {}

op1Set['-'] = true
op1Set['not'] = true
op1Set['#'] = true
op1Set['~'] = true
op1Set['*'] = true
op1Set['`'] = true
op1Set[',,'] = true
op1Set[',,,'] = true
op1Set[',,,,'] = true
local function getKindTxt( kind )
  return kind2Txt[kind] or _luneScript.error( 'unwrap val is nil' )
end
moduleObj.getKindTxt = getKindTxt
local function isOp2( ope )
  return op2Set[ope]
end
moduleObj.isOp2 = isOp2
local function isOp1( ope )
  return op1Set[ope]
end
moduleObj.isOp1 = isOp1
function StreamParser:parse(  )
  local function readLine(  )
    self.lineNo = self.lineNo + 1
    return self.stream:read( '*l' )
  end
  
  local rawLine = readLine(  )
  
      if  not rawLine then
        local _rawLine = rawLine
        
        return nil
      end
    
  local list = {}
  
  local startIndex = 1
  
  local multiComment = function ( comIndex, termStr )
    local searchIndex = comIndex
    
    local comment = ""
    
    while true do
      local termIndex, termEndIndex = string.find( rawLine, termStr, searchIndex, true )
      
      if termIndex then
        comment = comment .. rawLine:sub( searchIndex, termEndIndex )
        return comment, termEndIndex + 1
      end
      comment = comment .. rawLine:sub( searchIndex ) .. "\n"
      searchIndex = 1
      rawLine = readLine(  ) or _luneScript.error( 'unwrap val is nil' )
    end
  end
  
  
  local addVal = function ( kind, val, column )
    local function createInfo( tokenKind, token, tokenColumn )
      if tokenKind == kindSymb then
        if self.keywordSet[token] then
          tokenKind = kindKywd
        elseif self.typeSet[token] then
          tokenKind = kindType
        elseif op2Set[token] or op1Set[token] then
          tokenKind = kindOpe
        end
      end
      return Token.new(tokenKind, token, Position.new(self.lineNo, tokenColumn), {})
    end
    
    local function analyzeNumber( token, startIndex )
      local nonNumIndex = token:find( '[^%d]', startIndex )
      
      if not nonNumIndex then
        return #token, true
      end
      local intFlag = true
      
      local nonNumChar = token:byte( nonNumIndex )
      
      if nonNumChar == 46 then
        intFlag = false
        nonNumIndex = token:find( '[^%d]', nonNumIndex + 1 )
        nonNumChar = token:byte( nonNumIndex )
      end
      if nonNumChar == 120 or nonNumChar == 88 then
        nonNumIndex = token:find( '[^%d]', nonNumIndex + 1 )
        nonNumChar = token:byte( nonNumIndex )
      end
      if nonNumChar == 101 or nonNumChar == 69 then
        intFlag = false
        local nextChar = token:byte( nonNumIndex + 1 )
        
        if nextChar == 45 or nextChar == 43 then
          nonNumIndex = token:find( '[^%d]', nonNumIndex + 2 )
        else 
          nonNumIndex = token:find( '[^%d]', nonNumIndex + 1 )
        end
      end
      if not nonNumIndex then
        return #token, intFlag
      end
      return nonNumIndex - 1, intFlag
    end
    
    if kind == kindSymb then
      local searchIndex = 1
      
      while true do
        local tokenIndex, tokenEndIndex = string.find( val, "[%g]+", searchIndex )
        
        if not tokenIndex then
          break
        end
        local columnIndex = column + tokenIndex - 2
        
        searchIndex = tokenEndIndex + 1
        local token = val:sub( tokenIndex, tokenEndIndex )
        
        local startIndex = 1
        
        while true do
          if token:find( '^[%d]', startIndex ) then
            local endIndex, intFlag = analyzeNumber( token, startIndex )
            
            local info = createInfo( intFlag and kindInt or kindReal, token:sub( startIndex, endIndex ), columnIndex + startIndex )
            
            table.insert( list, info )
            startIndex = endIndex + 1
          else 
            local index = string.find( token, '[^%w_]', startIndex )
            
            if index then
              if index > startIndex then
                local info = createInfo( kindSymb, token:sub( startIndex, index - 1 ), columnIndex + startIndex )
                
                table.insert( list, info )
              end
              local delimit = token:sub( index, index )
              
              local candidateList = self.multiCharDelimitMap[delimit]
              
              while candidateList do
                local findFlag = false
                
                for __index, candidate in pairs( (candidateList ) or _luneScript.error( 'unwrap val is nil' ) ) do
                  if candidate == token:sub( index, index + #candidate - 1 ) then
                    delimit = candidate
                    candidateList = self.multiCharDelimitMap[delimit]
                    findFlag = true
                    break
                  end
                end
                if not findFlag then
                  break
                end
              end
              startIndex = index + #delimit
              local workKind = kindDlmt
              
              if op2Set[delimit] or op1Set[delimit] then
                workKind = kindOpe
              end
              if delimit == "..." then
                workKind = kindSymb
              end
              if delimit == "?" then
                local nextChar = token:sub( index, startIndex )
                
                table.insert( list, createInfo( kindChar, nextChar, columnIndex + startIndex ) )
                startIndex = startIndex + 1
              else 
                table.insert( list, createInfo( workKind, delimit, columnIndex + index ) )
              end
            else 
              if startIndex <= #token then
                table.insert( list, createInfo( kindSymb, token:sub( startIndex ), columnIndex + startIndex ) )
              end
              break
            end
          end
        end
      end
    else 
      table.insert( list, createInfo( kind, val, column ) )
    end
  end
  
  
  local searchIndex = startIndex
  
  while true do
    local syncIndexFlag = true
    
    local pattern = [==[[/%-%?"%'%`].]==]
    
    local index = string.find( rawLine, pattern, searchIndex )
    
    if not index then
      addVal( kindSymb, rawLine:sub( startIndex ), startIndex )
      return list
    end
    local findChar = string.byte( rawLine, index )
    
    local nextChar = string.byte( rawLine, index + 1 )
    
    if findChar == 45 and nextChar ~= 45 then
      searchIndex = index + 1
      syncIndexFlag = false
    else 
      if startIndex < index then
        addVal( kindSymb, rawLine:sub( startIndex, index - 1 ), startIndex )
      end
      if findChar == 47 then
        if nextChar == 42 then
          local comment, nextIndex = multiComment( index + 2, "*/" )
          
          addVal( kindCmnt, "/*" .. comment, index )
          searchIndex = nextIndex
        elseif nextChar == 47 then
          addVal( kindCmnt, rawLine:sub( index ), index )
          searchIndex = #rawLine + 1
        else 
          addVal( kindOpe, "/", index )
          searchIndex = index + 1
        end
      elseif findChar == 39 or findChar == 34 then
        local workIndex = index + 1
        
        local workPattern = '["\'\\]'
        
        while true do
          local endIndex = string.find( rawLine, workPattern, workIndex )
          
          if not endIndex then
            error( string.format( "illegal string: %d: %s", index, rawLine ) )
          end
          local workChar = string.byte( rawLine, endIndex )
          
          if workChar == findChar then
            addVal( kindStr, rawLine:sub( index, endIndex ), index )
            searchIndex = endIndex + 1
            break
          elseif workChar == 92 then
            workIndex = workIndex + 2
          else 
            workIndex = workIndex + 1
          end
        end
      elseif findChar == 96 then
        if (nextChar == findChar and string.byte( rawLine, index + 2 ) == 96 ) then
          local str, nextIndex = multiComment( index + 3, '```' )
          
          addVal( kindStr, '```' .. str, index )
          searchIndex = nextIndex
        else 
          addVal( kindOpe, '`', index )
          searchIndex = index + 1
        end
      elseif findChar == 63 then
        local codeChar = rawLine:sub( index + 1, index + 1 )
        
        if nextChar == 92 then
          local quoted = rawLine:sub( index + 2, index + 2 )
          
          if quotedCharSet[quoted] then
            codeChar = rawLine:sub( index + 1, index + 2 )
          else 
            codeChar = quoted
          end
          searchIndex = index + 3
        else 
          searchIndex = index + 2
        end
        addVal( kindChar, codeChar, index )
      else 
        error( string.format( "illegal syntax:%s:%s", self.lineNo, rawLine:sub( index ) ) )
      end
    end
    if syncIndexFlag then
      startIndex = searchIndex
    end
  end
end

function StreamParser:getToken(  )
  if not self.lineTokenList then
    return nil
  end
  if #self.lineTokenList < self.pos then
    self.pos = 1
    self.lineTokenList = {}
    while #self.lineTokenList == 0 do
      local workList = self:parse(  )
      
          if  not workList then
            local _workList = workList
            
            return nil
          end
        
      self.lineTokenList = workList
    end
  end
  local token = self.lineTokenList[self.pos]
  
  self.pos = self.pos + 1
  return token
end

local eofToken = Token.new(kindEof, "<EOF>", Position.new(0, 0), {})

local function getEofToken(  )
  return eofToken
end
moduleObj.getEofToken = getEofToken
local DummyParser = {}
setmetatable( DummyParser, { __index = Parser } )
moduleObj.DummyParser = DummyParser
function DummyParser:getToken(  )
  return eofToken
end
function DummyParser:getStreamName(  )
  return "dummy"
end
function DummyParser.new(  )
  local obj = {}
  setmetatable( obj, { __index = DummyParser } )
  if obj.__init then
    obj:__init(  )
  end        
  return obj 
 end         
function DummyParser:__init(  ) 
            
end
do
  end

return moduleObj
