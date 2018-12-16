--lune/base/Option.lns
local _moduleObj = {}
local __mod__ = 'lune.base.Option'
if not _lune then
   _lune = {}
end
function _lune.newAlge( kind, vals )
   local memInfoList = kind[ 2 ]
   if not memInfoList then
      return kind
   end
   return { kind[ 1 ], vals }
end

function _lune.unwrap( val )
   if val == nil then
      __luneScript:error( 'unwrap val is nil' )
   end
   return val
end 
function _lune.unwrapDefault( val, defval )
   if val == nil then
      return defval
   end
   return val
end

function _lune.loadModule( mod )
   if __luneScript then
      return  __luneScript:loadModule( mod )
   end
   return require( mod )
end

local Parser = _lune.loadModule( 'lune.base.Parser' )
local Util = _lune.loadModule( 'lune.base.Util' )
local LuaMod = _lune.loadModule( 'lune.base.LuaMod' )
local Ver = _lune.loadModule( 'lune.base.Ver' )
local LuaVer = _lune.loadModule( 'lune.base.LuaVer' )
local ModeKind = {}
_moduleObj.ModeKind = ModeKind
ModeKind._val2NameMap = {}
function ModeKind:_getTxt( val )
   local name = self._val2NameMap[ val ]
   if name then
      return string.format( "ModeKind.%s", name )
   end
   return string.format( "illegal val -- %s", val )
end 
function ModeKind._from( val )
   if ModeKind._val2NameMap[ val ] then
      return val
   end
   return nil
end 
    
ModeKind.__allList = {}
function ModeKind.get__allList()
   return ModeKind.__allList
end

ModeKind.Unknown = ''
ModeKind._val2NameMap[''] = 'Unknown'
ModeKind.__allList[1] = ModeKind.Unknown
ModeKind.Token = 'token'
ModeKind._val2NameMap['token'] = 'Token'
ModeKind.__allList[2] = ModeKind.Token
ModeKind.Ast = 'ast'
ModeKind._val2NameMap['ast'] = 'Ast'
ModeKind.__allList[3] = ModeKind.Ast
ModeKind.Diag = 'diag'
ModeKind._val2NameMap['diag'] = 'Diag'
ModeKind.__allList[4] = ModeKind.Diag
ModeKind.Complete = 'comp'
ModeKind._val2NameMap['comp'] = 'Complete'
ModeKind.__allList[5] = ModeKind.Complete
ModeKind.Lua = 'lua'
ModeKind._val2NameMap['lua'] = 'Lua'
ModeKind.__allList[6] = ModeKind.Lua
ModeKind.LuaMeta = 'LUA'
ModeKind._val2NameMap['LUA'] = 'LuaMeta'
ModeKind.__allList[7] = ModeKind.LuaMeta
ModeKind.Save = 'save'
ModeKind._val2NameMap['save'] = 'Save'
ModeKind.__allList[8] = ModeKind.Save
ModeKind.SaveMeta = 'SAVE'
ModeKind._val2NameMap['SAVE'] = 'SaveMeta'
ModeKind.__allList[9] = ModeKind.SaveMeta
ModeKind.Exec = 'exe'
ModeKind._val2NameMap['exe'] = 'Exec'
ModeKind.__allList[10] = ModeKind.Exec
ModeKind.Glue = 'glue'
ModeKind._val2NameMap['glue'] = 'Glue'
ModeKind.__allList[11] = ModeKind.Glue

local Option = {}
_moduleObj.Option = Option
function Option.new(  )
   local obj = {}
   Option.setmeta( obj )
   if obj.__init then obj:__init(  ); end
   return obj
end
function Option:__init() 
   self.validProf = false
   self.mode = ModeKind.Unknown
   self.scriptPath = ""
   self.useLuneModule = false
   self.updateOnLoad = false
   self.targetLuaVer = LuaVer.curVer
end
function Option.setmeta( obj )
  setmetatable( obj, { __index = Option  } )
end

local function outputLuneMod( dir )

   local path = "_lune.lua"
   do
      local _exp = dir
      if _exp ~= nil then
         if _exp ~= "" then
            path = _exp:gsub( "/$", "" ) .. "/" .. path
         end
         
      end
   end
   
   local fileObj = io.open( path, "w" )
   if  nil == fileObj then
      local _fileObj = fileObj
   
      return string.format( "failed to open -- %s", path)
   end
   
   for __index, kind in pairs( LuaMod.CodeKind.get__allList() ) do
      fileObj:write( LuaMod.getCode( kind ) )
   end
   
   fileObj:close(  )
   return nil
end
_moduleObj.outputLuneMod = outputLuneMod
local function analyze( argList )

   local function printUsage(  )
   
      print( [==[
usage:
  <type1> [-prof] [-r] src.lns mode [mode-option]
  <type2> -mklunemod dir
  <type3> --version

* type1
  - src.lns [common_op] ast
  - src.lns [common_op] comp [-i] module line column
  - src.lns [common_op] [-ol ver] <lua|LUA>
  - src.lns [common_op] [-ol ver] [--depends dependfile] <save|SAVE> output-dir
  - src.lns [common_op] exe

  -r: use 'require( "lune.base._lune" )'
  -ol: output lua version. ver = 51 or 52 or 53.
  --depends: output dependfile

  common_op:
    -u: update meta and lua on load.

* type2
  dir: output directory.
]==] )
      os.exit( 1 )
   end
   
   local option = Option.new()
   local useStdInFlag = false
   local lineNo = nil
   local column = nil
   local index = 1
   while #argList >= index do
      local arg = argList[index]
      if arg:find( "^-" ) then
         do
            local _switchExp = (arg )
            if _switchExp == "-i" then
               useStdInFlag = true
            elseif _switchExp == "-prof" then
               option.validProf = true
            elseif _switchExp == "--nodebug" then
               Util.setDebugFlag( false )
            elseif _switchExp == "--version" then
               print( string.format( "LuneScript: version %s", Ver.version) )
               os.exit( 0 )
            elseif _switchExp == "-mklunemod" then
               local path = (#argList > index ) and argList[index + 1] or nil
               do
                  local mess = outputLuneMod( path )
                  if mess ~= nil then
                     Util.errorLog( mess )
                     os.exit( 1 )
                  end
               end
               
               os.exit( 0 )
            elseif _switchExp == "-r" then
               option.useLuneModule = true
            elseif _switchExp == "-u" then
               option.updateOnLoad = true
            elseif _switchExp == "--depends" then
               if #argList > index then
                  do
                     local stream = io.open( argList[index + 1], "w" )
                     if stream ~= nil then
                        option.dependsStream = stream
                     else
                        Util.err( string.format( "failed to open -- %s", argList[index + 1]) )
                     end
                  end
                  
               end
               
               index = index + 1
            elseif _switchExp == "-ol" then
               if #argList > index then
                  do
                     local _switchExp = argList[index + 1]
                     if _switchExp == "51" then
                        option.targetLuaVer = LuaVer.ver51
                     elseif _switchExp == "52" then
                        option.targetLuaVer = LuaVer.ver52
                     elseif _switchExp == "53" then
                        option.targetLuaVer = LuaVer.ver53
                     end
                  end
                  
               end
               
               index = index + 1
            else 
               
                  Util.log( string.format( "unknown option -- %s", arg) )
                  os.exit( 1 )
            end
         end
         
      else
       
         if option.scriptPath == "" then
            option.scriptPath = arg
         elseif option.mode == "" then
            do
               local mode = ModeKind._from( arg )
               if mode ~= nil then
                  option.mode = mode
               else
                  Util.err( string.format( "unknown mode -- %s", arg) )
               end
            end
            
         else
          
            do
               local _switchExp = (option.mode )
               if _switchExp == ModeKind.Complete then
                  if not option.analyzeModule then
                     option.analyzeModule = arg
                  elseif not lineNo then
                     lineNo = math.floor(tonumber( arg ))
                  elseif not column then
                     column = math.floor(tonumber( arg ))
                     option.analyzePos = Parser.Position.new(_lune.unwrap( lineNo), _lune.unwrap( column))
                  end
                  
               elseif _switchExp == ModeKind.Save or _switchExp == ModeKind.SaveMeta or _switchExp == ModeKind.Glue then
                  option.outputDir = arg
               else 
                  
               end
            end
            
         end
         
      end
      
      index = index + 1
   end
   
   if option.scriptPath == "" or option.mode == ModeKind.Unknown then
      printUsage(  )
   end
   
   if useStdInFlag and option.analyzeModule then
      Parser.StreamParser.setStdinStream( _lune.unwrap( option.analyzeModule) )
   end
   
   return option
end
_moduleObj.analyze = analyze
return _moduleObj