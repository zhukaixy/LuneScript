--lune/base/TransUnit.lns
local _moduleObj = {}
if not _ENV._lune then
   _lune = {}
end
function _lune.nilacc( val, fieldName, access, ... )
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
    elseif access == "call" then
      return field( ... )
    elseif access == "callmtd" then
      return field( val, ... )
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
  elseif access == "call" then
    return val( ... )
  elseif access == "list" then
    local list, arg = ...
    if not list then
      return nil
    end
    return val( list, arg )
  end
  error( string.format( "illegal access -- %s", access ) )
end

function _lune.unwrap( val )
  if val == nil then
    _luneScript.error( 'unwrap val is nil' )
  end
  return val
end 
function _lune.unwrapDefault( val, defval )
  if val == nil then
    return defval
  end
  return val
end




local Parser = require( 'lune.base.Parser' )

local Util = require( 'lune.base.Util' )

local Ast = require( 'lune.base.Ast' )

local Writer = require( 'lune.base.Writer' )

local TransUnit = {}
_moduleObj.TransUnit = TransUnit
function TransUnit.new( macroEval, analyzeModule, mode, pos )
  local obj = {}
  setmetatable( obj, { __index = TransUnit } )
  if obj.__init then obj:__init( macroEval, analyzeModule, mode, pos ); end
return obj
end
function TransUnit:__init(macroEval, analyzeModule, mode, pos) 
  self.macroScope = nil
  self.validMutControl = true
  self.moduleName = ""
  self.parser = Parser.DummyParser.new()
  self.subfileList = {}
  self.pushbackList = {}
  self.usedTokenList = {}
  self.scope = Ast.rootScope
  self.moduleScope = Ast.rootScope
  self.typeId2ClassMap = {}
  self.typeInfo2ClassNode = {}
  self.currentToken = Parser.getEofToken(  )
  self.errMessList = {}
  self.macroEval = macroEval
  self.typeId2MacroInfo = {}
  self.macroMode = "none"
  self.symbol2ValueMapForMacro = {}
  self.analyzeMode = _lune.unwrapDefault( mode, "")
  self.analyzePos = _lune.unwrapDefault( pos, Parser.Position.new(0, 0))
  self.analyzeModule = _lune.unwrapDefault( analyzeModule, "")
  self.provideNode = nil
  self.useUnwrapExp = false
  self.useNilAccess = false
end
function TransUnit:addErrMess( pos, mess )
  table.insert( self.errMessList, string.format( "%s:%d:%d: error: %s", self.parser:getStreamName(  ), pos.lineNo, pos.column, mess) )
end
function TransUnit:pushScope( classFlag, inheritList )
  self.scope = Ast.Scope.new(self.scope, classFlag, _lune.unwrapDefault( inheritList, {}))
  return self.scope
end
function TransUnit:popScope(  )
  self.scope = self.scope:get_parent(  )
end
function TransUnit:getCurrentClass(  )
  local typeInfo = Ast.rootTypeInfo
  
  local scope = self.scope
  
  repeat 
    do
      local _exp = scope:get_ownerTypeInfo()
      if _exp ~= nil then
      
          if _exp:get_kind() == Ast.TypeInfoKind.Class or _exp:get_kind() == Ast.TypeInfoKind.Module or _exp:get_kind() == Ast.TypeInfoKind.IF then
            return _exp
          end
        end
    end
    
    scope = scope:get_parent()
  until scope == Ast.rootScope
  return typeInfo
end
function TransUnit:getCurrentNamespaceTypeInfo(  )
  local typeInfo = Ast.rootTypeInfo
  
  local scope = self.scope
  
  repeat 
    do
      local _exp = scope:get_ownerTypeInfo()
      if _exp ~= nil then
      
          return _exp
        end
    end
    
    scope = scope:get_parent()
  until scope == Ast.rootScope
  return typeInfo
end
function TransUnit:pushModule( externalFlag, name, mutable )
  local typeInfo = Ast.rootTypeInfo
  
  do
    local _exp = self.scope:getTypeInfoChild( name )
    if _exp ~= nil then
    
        typeInfo = _exp
        self.scope = _lune.unwrap( typeInfo:get_scope())
      else
    
        local parentInfo = self:getCurrentNamespaceTypeInfo(  )
        
        local parentScope = self.scope
        
        local scope = self:pushScope( true )
        
        typeInfo = Ast.NormalTypeInfo.createModule( scope, parentInfo, externalFlag, name, mutable )
        parentScope:addClass( name, typeInfo )
      end
  end
  
  if not self.typeId2ClassMap[typeInfo:get_typeId(  )] then
    local namespace = Ast.NamespaceInfo.new(name, self.scope, typeInfo)
    
    self.typeId2ClassMap[typeInfo:get_typeId(  )] = namespace
  end
  return typeInfo
end
function TransUnit:popModule(  )
  self:popScope(  )
end
function TransUnit:pushClass( classFlag, abstructFlag, baseInfo, interfaceList, externalFlag, name, accessMode, defNamespace )
  local typeInfo = Ast.rootTypeInfo
  
  do
    local _exp = self.scope:getTypeInfoChild( name )
    if _exp ~= nil then
    
        typeInfo = _exp
        self.scope = _lune.unwrap( typeInfo:get_scope())
        do
          local _switchExp = (_exp:get_kind() )
          if _switchExp == Ast.TypeInfoKind.Class then
            if not classFlag then
              self:addErrMess( self.currentToken.pos, string.format( "define interface already -- %s", name) )
              Util.printStackTrace(  )
            end
          elseif _switchExp == Ast.TypeInfoKind.IF then
            if classFlag then
              self:addErrMess( self.currentToken.pos, string.format( "define class already -- %s", name) )
              Util.printStackTrace(  )
            end
          end
        end
        
      else
    
        local parentInfo = self:getCurrentNamespaceTypeInfo(  )
        
        local inheritList = {}
        
        do
          local _exp = baseInfo
          if _exp ~= nil then
          
              inheritList = {_lune.unwrap( _exp:get_scope(  ))}
            end
        end
        
        local parentScope = self.scope
        
        local scope = self:pushScope( true, inheritList )
        
        typeInfo = Ast.NormalTypeInfo.createClass( classFlag, abstructFlag, scope, baseInfo, interfaceList, parentInfo, externalFlag, accessMode, name )
        parentScope:addClass( name, typeInfo )
      end
  end
  
  local namespace = defNamespace
  
      if  nil == namespace then
        local _namespace = namespace
        
        namespace = Ast.NamespaceInfo.new(name, self.scope, typeInfo)
      end
    
  self.typeId2ClassMap[typeInfo:get_typeId(  )] = namespace
  return typeInfo
end
function TransUnit:popClass(  )
  self:popScope(  )
end
-- none
-- none
-- none
-- none
-- none
-- none
-- none
-- none
-- none
-- none
function TransUnit:get_errMessList()       
  return self.errMessList         
end
do
  end

local opLevelBase = 0

local op2levelMap = {}

local op1levelMap = {}

local function regOpLevel( opnum, opList )
  opLevelBase = opLevelBase + 1
  if opnum == 1 then
    for __index, op in pairs( opList ) do
      op1levelMap[op] = opLevelBase
    end
  else 
    for __index, op in pairs( opList ) do
      op2levelMap[op] = opLevelBase
    end
  end
end

regOpLevel( 2, {"="} )
regOpLevel( 2, {"or"} )
regOpLevel( 2, {"and"} )
regOpLevel( 2, {"<", ">", "<=", ">=", "~=", "=="} )
regOpLevel( 2, {"|"} )
regOpLevel( 2, {"~"} )
regOpLevel( 2, {"&"} )
regOpLevel( 2, {"<<", ">>"} )
regOpLevel( 2, {".."} )
regOpLevel( 2, {"+", "-"} )
regOpLevel( 2, {"*", "/", "//", "%"} )
regOpLevel( 1, {"`", ",,", ",,,", ",,,,"} )
regOpLevel( 1, {"not", "#", "-", "~"} )
regOpLevel( 1, {"^"} )
local quotedChar2Code = {}

quotedChar2Code['a'] = 7
quotedChar2Code['b'] = 8
quotedChar2Code['t'] = 9
quotedChar2Code['n'] = 10
quotedChar2Code['v'] = 11
quotedChar2Code['f'] = 12
quotedChar2Code['r'] = 13
quotedChar2Code['\\'] = 92
quotedChar2Code['"'] = 34
quotedChar2Code["'"] = 39
local _TypeInfo = {}
function _TypeInfo.new( abstructFlag, baseId, ifList, itemTypeId, argTypeId, retTypeId, parentId, typeId, txt, kind, staticFlag, nilable, orgTypeId, children, accessMode, valTypeId, enumValList, mutable, srcTypeId )
  local obj = {}
  setmetatable( obj, { __index = _TypeInfo } )
  if obj.__init then
    obj:__init( abstructFlag, baseId, ifList, itemTypeId, argTypeId, retTypeId, parentId, typeId, txt, kind, staticFlag, nilable, orgTypeId, children, accessMode, valTypeId, enumValList, mutable, srcTypeId )
  end        
  return obj 
end         
function _TypeInfo:__init( abstructFlag, baseId, ifList, itemTypeId, argTypeId, retTypeId, parentId, typeId, txt, kind, staticFlag, nilable, orgTypeId, children, accessMode, valTypeId, enumValList, mutable, srcTypeId ) 

self.abstructFlag = abstructFlag
  self.baseId = baseId
  self.ifList = ifList
  self.itemTypeId = itemTypeId
  self.argTypeId = argTypeId
  self.retTypeId = retTypeId
  self.parentId = parentId
  self.typeId = typeId
  self.txt = txt
  self.kind = kind
  self.staticFlag = staticFlag
  self.nilable = nilable
  self.orgTypeId = orgTypeId
  self.children = children
  self.accessMode = accessMode
  self.valTypeId = valTypeId
  self.enumValList = enumValList
  self.mutable = mutable
  self.srcTypeId = srcTypeId
  end
do
  end

local _ModuleInfo = {}
function _ModuleInfo.new( _typeId2ClassInfoMap, _typeInfoList, _varName2InfoMap, _funcName2InfoMap, _moduleTypeId, _moduleMutable )
  local obj = {}
  setmetatable( obj, { __index = _ModuleInfo } )
  if obj.__init then
    obj:__init( _typeId2ClassInfoMap, _typeInfoList, _varName2InfoMap, _funcName2InfoMap, _moduleTypeId, _moduleMutable )
  end        
  return obj 
end         
function _ModuleInfo:__init( _typeId2ClassInfoMap, _typeInfoList, _varName2InfoMap, _funcName2InfoMap, _moduleTypeId, _moduleMutable ) 

self._typeId2ClassInfoMap = _typeId2ClassInfoMap
  self._typeInfoList = _typeInfoList
  self._varName2InfoMap = _varName2InfoMap
  self._funcName2InfoMap = _funcName2InfoMap
  self._moduleTypeId = _moduleTypeId
  self._moduleMutable = _moduleMutable
  end
do
  end

local typeInfoListInsert = Ast.typeInfoRoot

_moduleObj.typeInfoListInsert = typeInfoListInsert

local typeInfoListRemove = Ast.typeInfoRoot

_moduleObj.typeInfoListRemove = typeInfoListRemove

function TransUnit:createModifier( typeInfo, mutable )
  if not self.validMutControl then
    return typeInfo
  end
  return Ast.NormalTypeInfo.createModifier( typeInfo, mutable )
end

function TransUnit:registBuiltInScope(  )
  local builtInInfo = {{[""] = {["type"] = {["arg"] = {"&stem!"}, ["ret"] = {"str"}}, ["error"] = {["arg"] = {"&str"}, ["ret"] = {}}, ["print"] = {["arg"] = {"&..."}, ["ret"] = {}}, ["tonumber"] = {["arg"] = {"&str", "&int!"}, ["ret"] = {"real"}}, ["load"] = {["arg"] = {"&str"}, ["ret"] = {"form!", "str"}}, ["require"] = {["arg"] = {"&str"}, ["ret"] = {"stem!"}}, ["_fcall"] = {["arg"] = {"&form", "&..."}, ["ret"] = {""}}}}, {["iStream"] = {["__attrib"] = {["type"] = {"interface"}}, ["read"] = {["type"] = {"mut"}, ["arg"] = {"&stem!"}, ["ret"] = {"str!"}}, ["close"] = {["type"] = {"mut"}, ["arg"] = {}, ["ret"] = {}}}}, {["oStream"] = {["__attrib"] = {["type"] = {"interface"}}, ["write"] = {["type"] = {"mut"}, ["arg"] = {"&str"}, ["ret"] = {}}, ["close"] = {["type"] = {"mut"}, ["arg"] = {}, ["ret"] = {}}}}, {["luaStream"] = {["__attrib"] = {["inplements"] = {"iStream", "oStream"}}, ["read"] = {["type"] = {"mut"}, ["arg"] = {"&stem!"}, ["ret"] = {"str!"}}, ["write"] = {["type"] = {"mut"}, ["arg"] = {"&str"}, ["ret"] = {}}, ["close"] = {["type"] = {"mut"}, ["arg"] = {}, ["ret"] = {}}}}, {["io"] = {["stdin"] = {["type"] = {"member"}, ["typeInfo"] = {"iStream"}}, ["stdout"] = {["type"] = {"member"}, ["typeInfo"] = {"oStream"}}, ["stderr"] = {["type"] = {"member"}, ["typeInfo"] = {"oStream"}}, ["open"] = {["arg"] = {"&str", "&str!"}, ["ret"] = {"luaStream!"}}, ["popen"] = {["arg"] = {"&str"}, ["ret"] = {"luaStream!"}}}}, {["os"] = {["clock"] = {["arg"] = {}, ["ret"] = {"int"}}, ["exit"] = {["arg"] = {"&int!"}, ["ret"] = {}}}}, {["string"] = {["find"] = {["arg"] = {"&str", "&str", "&int!", "&bool!"}, ["ret"] = {"int", "int"}}, ["byte"] = {["arg"] = {"&str", "&int"}, ["ret"] = {"int"}}, ["format"] = {["arg"] = {"&str", "..."}, ["ret"] = {"str"}}, ["rep"] = {["arg"] = {"&str", "&int"}, ["ret"] = {"str"}}, ["gmatch"] = {["arg"] = {"&str", "&str"}, ["ret"] = {"stem!"}}, ["gsub"] = {["arg"] = {"&str", "&str", "&str"}, ["ret"] = {"str"}}, ["sub"] = {["arg"] = {"&str", "&int", "&int!"}, ["ret"] = {"str"}}}}, {["str"] = {["find"] = {["type"] = {"method"}, ["arg"] = {"&str", "&int!", "&bool!"}, ["ret"] = {"int", "int"}}, ["byte"] = {["type"] = {"method"}, ["arg"] = {"&int"}, ["ret"] = {"int"}}, ["format"] = {["type"] = {"method"}, ["arg"] = {"&..."}, ["ret"] = {"str"}}, ["rep"] = {["type"] = {"method"}, ["arg"] = {"&int"}, ["ret"] = {"str"}}, ["gmatch"] = {["type"] = {"method"}, ["arg"] = {"&str"}, ["ret"] = {"stem!"}}, ["gsub"] = {["type"] = {"method"}, ["arg"] = {"&str", "&str"}, ["ret"] = {"str"}}, ["sub"] = {["type"] = {"method"}, ["arg"] = {"&int", "&int!"}, ["ret"] = {"str"}}}}, {["table"] = {["unpack"] = {["arg"] = {"&stem"}, ["ret"] = {"..."}}}}, {["List"] = {["insert"] = {["type"] = {"mut"}, ["arg"] = {"&stem"}, ["ret"] = {""}}, ["remove"] = {["type"] = {"mut"}, ["arg"] = {"&int!"}, ["ret"] = {""}}}}, {["debug"] = {["getinfo"] = {["arg"] = {"&int"}, ["ret"] = {"stem"}}}}, {["_luneScript"] = {["loadModule"] = {["arg"] = {"&str"}, ["ret"] = {"stem", "stem"}}, ["searchModule"] = {["arg"] = {"&str"}, ["ret"] = {"str!"}}}}}
  
  local function getTypeInfo( typeName )
    local mutable = true
    
    if typeName:find( "^&" ) then
      mutable = false
      typeName = typeName:gsub( "^&", "" )
    end
    local typeInfo = Ast.rootTypeInfo
    
    if typeName:find( "!$" ) then
      local orgTypeName = typeName:gsub( "!$", "" )
      
      typeInfo = _lune.unwrap( Ast.rootScope:getTypeInfo( orgTypeName, Ast.rootScope, false ))
      typeInfo = typeInfo:get_nilableTypeInfo()
    else 
      typeInfo = _lune.unwrap( Ast.rootScope:getTypeInfo( typeName, Ast.rootScope, false ))
    end
    if mutable then
      return typeInfo
    end
    typeInfo = self:createModifier( typeInfo, false )
    return typeInfo
  end
  
  local builtinModuleName2Scope = {}
  
  self.scope:addVar( "global", "_VERSION", Ast.builtinTypeString, false, true )
  for __index, builtinClassInfo in pairs( builtInInfo ) do
    for name, name2FieldInfo in pairs( builtinClassInfo ) do
      local parentInfo = Ast.typeInfoRoot
      
      if name ~= "" then
        local classFlag = true
        
        if _lune.nilacc( _lune.nilacc( name2FieldInfo['__attrib'], nil, 'item', 'type'), nil, 'item', 1) == "interface" then
          classFlag = false
        end
        local interfaceList = {}
        
        do
          local _exp = _lune.nilacc( name2FieldInfo['__attrib'], nil, 'item', 'inplements')
          if _exp ~= nil then
          
              for __index, ifname in pairs( _exp ) do
                local ifType = getTypeInfo( ifname )
                
                table.insert( interfaceList, ifType )
              end
            end
        end
        
        parentInfo = self:pushClass( classFlag, false, nil, interfaceList, true, name, "pub" )
        Ast.builtInTypeIdSet[parentInfo:get_typeId(  )] = parentInfo
        Ast.builtInTypeIdSet[parentInfo:get_nilableTypeInfo():get_typeId()] = parentInfo:get_nilableTypeInfo()
      end
      if not parentInfo then
        Util.err( "parentInfo is nil" )
      end
      if not builtinModuleName2Scope[name] then
        if name ~= "" and getTypeInfo( name ) then
          builtinModuleName2Scope[name] = self.scope
        end
        do
          local __sorted = {}
          local __map = name2FieldInfo
          for __key in pairs( __map ) do
            table.insert( __sorted, __key )
          end
          table.sort( __sorted )
          for __index, fieldName in ipairs( __sorted ) do
            info = __map[ fieldName ]
            do
              if fieldName ~= "__attrib" then
                if _lune.nilacc( info['type'], nil, 'item', 1) == "member" then
                  self.scope:addMember( fieldName, getTypeInfo( _lune.unwrap( _lune.nilacc( info['typeInfo'], nil, 'item', 1)) ), "pub", true, false )
                else 
                  local argTypeList = {}
                  
                  for __index, argType in pairs( _lune.unwrap( info["arg"]) ) do
                    table.insert( argTypeList, getTypeInfo( argType ) )
                  end
                  local retTypeList = {}
                  
                  for __index, retType in pairs( _lune.unwrap( info["ret"]) ) do
                    local retTypeInfo = getTypeInfo( retType )
                    
                    table.insert( retTypeList, retTypeInfo )
                  end
                  local funcType = _lune.nilacc( info['type'], nil, 'item', 1)
                  
                  local methodFlag = funcType == "method" or funcType == "mut"
                  
                  local mutable = funcType == "mut"
                  
                  self:pushScope( false )
                  local typeInfo = Ast.NormalTypeInfo.createFunc( false, true, self.scope, methodFlag and Ast.TypeInfoKind.Method or Ast.TypeInfoKind.Func, parentInfo, false, true, not methodFlag, "pub", fieldName, argTypeList, retTypeList, mutable )
                  
                  self:popScope(  )
                  Ast.builtInTypeIdSet[typeInfo:get_typeId(  )] = typeInfo
                  if typeInfo:get_nilableTypeInfo() ~= Ast.rootTypeInfo then
                    Ast.builtInTypeIdSet[typeInfo:get_nilableTypeInfo():get_typeId()] = typeInfo:get_nilableTypeInfo()
                  end
                  self.scope:add( methodFlag and Ast.SymbolKind.Mtd or Ast.SymbolKind.Fun, not methodFlag, not methodFlag, fieldName, typeInfo, "pub", not methodFlag, mutable, true )
                  if methodFlag then
                    do
                      local _switchExp = (name )
                      if _switchExp == "List" then
                        do
                          local _switchExp = (fieldName )
                          if _switchExp == "insert" then
                            _moduleObj.typeInfoListInsert = typeInfo
                          elseif _switchExp == "remove" then
                            _moduleObj.typeInfoListRemove = typeInfo
                          end
                        end
                        
                      end
                    end
                    
                  end
                end
              end
            end
          end
        end
        
      end
      if name ~= "" then
        self:popClass(  )
      end
    end
  end
end

function TransUnit:error( mess )
  local pos = Parser.Position.new(0, 0)
  
  local txt = ""
  
  if self.currentToken ~= Parser.getEofToken(  ) then
    pos = self.currentToken.pos
    txt = self.currentToken.txt
  else 
    if #self.usedTokenList > 0 then
      local token = self.usedTokenList[#self.usedTokenList]
      
      pos = token.pos
      txt = token.txt
    end
  end
  self:addErrMess( pos, mess )
  for __index, mess in pairs( self.errMessList ) do
    Util.errorLog( mess )
  end
  Util.err( "has error" )
end

function TransUnit:createNoneNode( pos )
  return Ast.NoneNode.new(pos, {Ast.builtinTypeNone})
end

function TransUnit:pushbackToken( token )
  if token ~= Parser.getEofToken(  ) then
    table.insert( self.pushbackList, token )
  end
  self.currentToken = self.usedTokenList[#self.usedTokenList]
end

local function expandVal( tokenList, val, pos )
  do
    local _exp = val
    if _exp ~= nil then
    
        do
          local _switchExp = type( _exp )
          if _switchExp == "boolean" then
            local token = string.format( "%s", _exp)
            
            local kind = Parser.TokenKind.Kywd
            
            table.insert( tokenList, Parser.Token.new(kind, token, pos) )
          elseif _switchExp == "number" then
            local num = string.format( "%g", _exp)
            
            local kind = Parser.TokenKind.Int
            
            if string.find( num, ".", 1, true ) then
              kind = Parser.TokenKind.Real
            end
            table.insert( tokenList, Parser.Token.new(kind, num, pos) )
          elseif _switchExp == "string" then
            table.insert( tokenList, Parser.Token.new(Parser.TokenKind.Str, string.format( '[[%s]]', _exp), pos) )
          elseif _switchExp == "table" then
            table.insert( tokenList, Parser.Token.new(Parser.TokenKind.Dlmt, string.format( "{", _exp), pos) )
            for key, item in pairs( _exp ) do
              expandVal( tokenList, item, pos )
              table.insert( tokenList, Parser.Token.new(Parser.TokenKind.Dlmt, string.format( ",", _exp), pos) )
            end
            table.insert( tokenList, Parser.Token.new(Parser.TokenKind.Dlmt, string.format( "}", _exp), pos) )
          end
        end
        
      end
  end
  
end

function TransUnit:newPushback( tokenList )
  for index = #tokenList, 1, -1 do
    table.insert( self.pushbackList, tokenList[index] )
  end
  self.currentToken = self.usedTokenList[#self.usedTokenList]
end

function TransUnit:getTokenNoErr(  )
  if #self.pushbackList > 0 then
    if self.currentToken ~= Parser.getEofToken(  ) then
      table.insert( self.usedTokenList, self.currentToken )
    end
    self.currentToken = self.pushbackList[#self.pushbackList]
    table.remove( self.pushbackList )
    return self.currentToken
  end
  local commentList = {}
  
  local token = nil
  
  while true do
    token = self.parser:getToken(  )
    do
      local _exp = token
      if _exp ~= nil then
      
          if _exp.kind ~= Parser.TokenKind.Cmnt then
            break
          end
          table.insert( commentList, _exp )
        else
      
          break
        end
    end
    
  end
  do
    local _exp = token
    if _exp ~= nil then
    
        if self.macroMode == "expand" then
          local tokenTxt = _exp.txt
          
          if tokenTxt == ',,' or tokenTxt == ',,,,' then
            local nextToken = self:getTokenNoErr(  )
            
            local macroVal = self.symbol2ValueMapForMacro[nextToken.txt]
            
                if  nil == macroVal then
                  local _macroVal = macroVal
                  
                  self:error( string.format( "unknown macro val %s", nextToken.txt) )
                end
              
            if tokenTxt == ',,' then
              if macroVal.typeInfo:equals( Ast.builtinTypeSymbol ) then
                local txtList = (_lune.unwrap( macroVal.val) )
                
                for index = #txtList, 1, -1 do
                  nextToken = Parser.Token.new(nextToken.kind, txtList[index], nextToken.pos)
                  self:pushbackToken( nextToken )
                end
              elseif macroVal.typeInfo:equals( Ast.builtinTypeStat ) then
                self:pushbackStr( string.format( "macroVal %s", nextToken.txt), (_lune.unwrap( macroVal.val) ) )
              elseif macroVal.typeInfo:get_kind(  ) == Ast.TypeInfoKind.Array or macroVal.typeInfo:get_kind(  ) == Ast.TypeInfoKind.List then
                local strList = (_lune.unwrap( macroVal.val) )
                
                if strList then
                  for index = #strList, 1, -1 do
                    self:pushbackStr( string.format( "macroVal %s[%d]", nextToken.txt, index), strList[index] )
                  end
                else 
                  self:error( string.format( "macro val is nil %s", nextToken.txt) )
                end
              else 
                local tokenList = {}
                
                expandVal( tokenList, macroVal.val, nextToken.pos )
                self:newPushback( tokenList )
              end
            elseif tokenTxt == ',,,,' then
              if macroVal.typeInfo:equals( Ast.builtinTypeSymbol ) then
                local txtList = (_lune.unwrap( macroVal.val) )
                
                local newToken = ""
                
                for __index, txt in pairs( txtList ) do
                  newToken = string.format( "%s%s", newToken, txt)
                end
                nextToken = Parser.Token.new(Parser.TokenKind.Str, string.format( "'%s'", newToken), nextToken.pos)
                self:pushbackToken( nextToken )
              elseif macroVal.typeInfo:equals( Ast.builtinTypeStat ) then
                nextToken = Parser.Token.new(Parser.TokenKind.Str, string.format( "'%s'", _lune.unwrap( macroVal.val)), nextToken.pos)
                self:pushbackToken( nextToken )
              else 
                self:error( string.format( "not support this symbol -- %s%s", tokenTxt, nextToken.txt) )
              end
            end
            nextToken = self:getTokenNoErr(  )
            token = nextToken
          end
        end
      end
  end
  
  table.insert( self.usedTokenList, self.currentToken )
  self.currentToken = _lune.unwrapDefault( token, Parser.getEofToken(  ))
  return self.currentToken
end

function TransUnit:getToken( allowEof )
  local token = self:getTokenNoErr(  )
  
  if token == Parser.getEofToken(  ) then
    if allowEof then
      return Parser.getEofToken(  )
    end
    self:error( "EOF" )
  end
  -- none
  
  self.currentToken = token
  return token
end

function TransUnit:pushback(  )
  if self.currentToken ~= Parser.getEofToken(  ) then
    table.insert( self.pushbackList, self.currentToken )
  end
  self.currentToken = self.usedTokenList[#self.usedTokenList]
  table.remove( self.usedTokenList )
end

function TransUnit:pushbackStr( name, statement )
  local memStream = Parser.TxtStream.new(statement)
  
  local parser = Parser.StreamParser.new(memStream, name, false)
  
  local list = {}
  
  while true do
    do
      local _exp = parser:getToken(  )
      if _exp ~= nil then
      
          table.insert( list, _exp )
        else
      
          break
        end
    end
    
  end
  for index = #list, 1, -1 do
    self:pushbackToken( list[index] )
  end
end

function TransUnit:checkSymbol( token )
  if token.kind ~= Parser.TokenKind.Symb and token.kind ~= Parser.TokenKind.Kywd and token.kind ~= Parser.TokenKind.Type then
    self:error( "illegal symbol" )
  end
  return token
end

function TransUnit:getSymbolToken(  )
  return self:checkSymbol( self:getToken(  ) )
end

function TransUnit:checkToken( token, txt )
  if not token or token.txt ~= txt then
    self:error( string.format( "not found -- %s", txt) )
  end
  return token
end

function TransUnit:checkNextToken( txt )
  return self:checkToken( self:getToken(  ), txt )
end

function TransUnit:getContinueToken(  )
  local prevToken = self.currentToken
  
      if  nil == prevToken then
        local _prevToken = prevToken
        
        return self:getToken(  ), false
      end
    
  local token = self:getToken(  )
  
  if prevToken.pos.lineNo ~= token.pos.lineNo or prevToken.pos.column + #prevToken.txt ~= token.pos.column then
    return token, false
  end
  return token, true
end

function TransUnit:analyzeStatementList( stmtList, termTxt )
  local lastStatement = nil
  
  while true do
    local statement = self:analyzeStatement( termTxt )
    
    do
      local _exp = statement
      if _exp ~= nil then
      
          table.insert( stmtList, _exp )
          lastStatement = statement
        else
      
          break
        end
    end
    
  end
  return lastStatement
end

function TransUnit:analyzeStatementListSubfile( stmtList )
  local statement = self:analyzeStatement(  )
  
  do
    local _exp = statement
    if _exp ~= nil then
    
        if _exp:get_kind() ~= Ast.nodeKindSubfile then
          self:error( "subfile must have 'subfile' declaration at top." )
        end
      else
    
        self:error( "subfile must have 'subfile' declaration at top." )
      end
  end
  
  return self:analyzeStatementList( stmtList )
end

function TransUnit:analyzeLuneControl( firstToken )
  local nextToken = self:getToken(  )
  
  do
    local _switchExp = (nextToken.txt )
    if _switchExp == "disable_mut_control" then
      self.validMutControl = false
    else 
      self:addErrMess( nextToken.pos, string.format( "unknown option -- %s", nextToken.txt) )
    end
  end
  
  self:checkNextToken( ";" )
end

function TransUnit:analyzeBlock( blockKind, scope )
  local token = self:checkNextToken( "{" )
  
  if not scope then
    self:pushScope( false )
  end
  local stmtList = {}
  
  self:analyzeStatementList( stmtList, "}" )
  self:checkNextToken( "}" )
  if not scope then
    self:popScope(  )
  end
  local node = Ast.BlockNode.new(token.pos, {Ast.builtinTypeNone}, blockKind, stmtList)
  
  return node
end

function TransUnit:analyzeImport( token )
  if self.moduleScope ~= self.scope then
    self:error( "'import' must call at top scope." )
  end
  self.scope = Ast.rootScope
  local moduleToken = self:getToken(  )
  
  local modulePath = moduleToken.txt
  
  local nextToken = moduleToken
  
  local nameList = {moduleToken.txt}
  
  while true do
    nextToken = self:getToken(  )
    if nextToken.txt == "." then
      nextToken = self:getToken(  )
      moduleToken = nextToken
      modulePath = string.format( "%s.%s", modulePath, moduleToken.txt)
      table.insert( nameList, moduleToken.txt )
    else 
      break
    end
  end
  local _obj, _obj2 = _luneScript.loadModule( modulePath )
  
  local moduleInfo = _obj2
  
  local typeId2TypeInfo = {}
  
  typeId2TypeInfo[Ast.rootTypeId] = Ast.typeInfoRoot
  for index, moduleName in pairs( nameList ) do
    local mutable = false
    
    if index == #nameList then
      mutable = moduleInfo._moduleMutable
    end
    self:pushModule( true, moduleName, mutable )
  end
  for __index, moduleName in pairs( nameList ) do
    self:popModule(  )
  end
  for __index, symbolInfo in pairs( Ast.sym2builtInTypeMap ) do
    typeId2TypeInfo[symbolInfo:get_typeInfo():get_typeId(  )] = symbolInfo:get_typeInfo()
  end
  for __index, builtinTypeInfo in pairs( Ast.builtInTypeIdSet ) do
    typeId2TypeInfo[builtinTypeInfo:get_typeId()] = builtinTypeInfo
  end
  local typeId2Scope = {}
  
  typeId2Scope[Ast.rootTypeId] = self.scope
  local newId2OldIdMap = {}
  
  local function registTypeInfo( atomInfo )
    local newTypeInfo = nil
    
    do
      local _exp = atomInfo.srcTypeId
      if _exp ~= nil then
      
          local srcTypeInfo = _lune.unwrap( typeId2TypeInfo[_exp])
          
          newTypeInfo = self:createModifier( srcTypeInfo, _lune.unwrapDefault( atomInfo.mutable, false) )
          typeId2TypeInfo[atomInfo.typeId] = newTypeInfo
        else
      
          if atomInfo.kind == Ast.TypeInfoKind.Enum then
            local parentInfo = _lune.unwrap( typeId2TypeInfo[atomInfo.parentId])
            
            local name2EnumValInfo = {}
            
            local parentScope = _lune.unwrap( parentInfo:get_scope())
            
            local scope = Ast.Scope.new(parentScope, true, {})
            
            typeId2Scope[atomInfo.typeId] = scope
            local enumTypeInfo = Ast.NormalTypeInfo.createEnum( scope, _lune.unwrap( parentInfo), true, atomInfo.accessMode, atomInfo.txt, _lune.unwrap( typeId2TypeInfo[atomInfo.valTypeId]), name2EnumValInfo )
            
            newTypeInfo = enumTypeInfo
            typeId2TypeInfo[atomInfo.typeId] = enumTypeInfo
            for valName, valData in pairs( atomInfo.enumValList ) do
              name2EnumValInfo[valName] = Ast.EnumValInfo.new(valName, valData)
              scope:addEnumVal( valName, enumTypeInfo )
            end
            parentScope:addEnum( atomInfo.accessMode, atomInfo.txt, enumTypeInfo )
          elseif atomInfo.kind == Ast.TypeInfoKind.Module then
            local parentInfo = Ast.typeInfoRoot
            
            if atomInfo.parentId ~= Ast.rootTypeId then
              local workTypeInfo = typeId2TypeInfo[atomInfo.parentId]
              
                  if  nil == workTypeInfo then
                    local _workTypeInfo = workTypeInfo
                    
                    Util.err( string.format( "not found parentInfo %s %s", atomInfo.parentId, atomInfo.txt) )
                  end
                
              parentInfo = workTypeInfo
            end
            local parentScope = typeId2Scope[atomInfo.parentId]
            
                if  nil == parentScope then
                  local _parentScope = parentScope
                  
                  self:error( string.format( "not found parentScope %s %s", atomInfo.parentId, atomInfo.txt) )
                end
              
            newTypeInfo = parentScope:getTypeInfoChild( atomInfo.txt )
            do
              local _exp = newTypeInfo
              if _exp ~= nil then
              
                  typeId2Scope[atomInfo.typeId] = _exp:get_scope()
                  if not _exp:get_scope() then
                    Util.err( string.format( "not found scope %s %s %s %s %s", parentScope, atomInfo.parentId, atomInfo.typeId, atomInfo.txt, _exp:getTxt(  )) )
                  end
                  typeId2TypeInfo[atomInfo.typeId] = _exp
                else
              
                  local scope = Ast.Scope.new(parentScope, true, {})
                  
                  local mutable = false
                  
                  if atomInfo.typeId == moduleInfo._moduleTypeId then
                    mutable = moduleInfo._moduleMutable
                  end
                  local workTypeInfo = Ast.NormalTypeInfo.createModule( scope, parentInfo, true, atomInfo.txt, mutable )
                  
                  newTypeInfo = workTypeInfo
                  typeId2Scope[atomInfo.typeId] = scope
                  typeId2TypeInfo[atomInfo.typeId] = workTypeInfo
                  parentScope:addClass( atomInfo.txt, workTypeInfo )
                end
            end
            
          elseif atomInfo.parentId ~= Ast.rootTypeId or not Ast.builtInTypeIdSet[atomInfo.typeId] or atomInfo.kind == Ast.TypeInfoKind.List or atomInfo.kind == Ast.TypeInfoKind.Array or atomInfo.kind == Ast.TypeInfoKind.Map or atomInfo.nilable then
            if atomInfo.nilable then
              local orgTypeInfo = _lune.unwrap( typeId2TypeInfo[atomInfo.orgTypeId])
              
              newTypeInfo = orgTypeInfo:get_nilableTypeInfo(  )
              typeId2TypeInfo[atomInfo.typeId] = _lune.unwrap( newTypeInfo)
            else 
              local parentInfo = Ast.typeInfoRoot
              
              if atomInfo.parentId ~= Ast.rootTypeId then
                local workTypeInfo = typeId2TypeInfo[atomInfo.parentId]
                
                    if  nil == workTypeInfo then
                      local _workTypeInfo = workTypeInfo
                      
                      Util.err( string.format( "not found parentInfo %s %s", atomInfo.parentId, atomInfo.txt) )
                    end
                  
                parentInfo = workTypeInfo
              end
              local itemTypeInfo = {}
              
              for __index, typeId in pairs( atomInfo.itemTypeId ) do
                table.insert( itemTypeInfo, _lune.unwrap( typeId2TypeInfo[typeId]) )
              end
              local argTypeInfo = {}
              
              for __index, typeId in pairs( atomInfo.argTypeId ) do
                if not typeId2TypeInfo[typeId] then
                  Util.log( string.format( "not found -- %s.%s, %d, %d", parentInfo:getTxt(  ), atomInfo.txt, typeId, #atomInfo.argTypeId) )
                end
                table.insert( argTypeInfo, _lune.unwrap( typeId2TypeInfo[typeId]) )
              end
              local retTypeInfo = {}
              
              for __index, typeId in pairs( atomInfo.retTypeId ) do
                table.insert( retTypeInfo, _lune.unwrap( typeId2TypeInfo[typeId]) )
              end
              local baseInfo = _lune.unwrap( typeId2TypeInfo[atomInfo.baseId])
              
              local interfaceList = {}
              
              for __index, ifTypeId in pairs( atomInfo.ifList ) do
                table.insert( interfaceList, _lune.unwrap( typeId2TypeInfo[ifTypeId]) )
              end
              local parentScope = typeId2Scope[atomInfo.parentId]
              
                  if  nil == parentScope then
                    local _parentScope = parentScope
                    
                    self:error( string.format( "not found parentScope %s %s", atomInfo.parentId, atomInfo.txt) )
                  end
                
              if atomInfo.txt ~= "" then
                newTypeInfo = parentScope:getTypeInfoChild( atomInfo.txt )
              end
              if newTypeInfo and (atomInfo.kind == Ast.TypeInfoKind.Class or atomInfo.kind == Ast.TypeInfoKind.IF ) then
                do
                  local _exp = newTypeInfo
                  if _exp ~= nil then
                  
                      typeId2Scope[atomInfo.typeId] = _exp:get_scope()
                      if not _exp:get_scope() then
                        Util.err( string.format( "not found scope %s %s %s %s %s", parentScope, atomInfo.parentId, atomInfo.typeId, atomInfo.txt, _exp:getTxt(  )) )
                      end
                      typeId2TypeInfo[atomInfo.typeId] = _exp
                    end
                end
                
                -- none
                
              else 
                if atomInfo.kind == Ast.TypeInfoKind.Class or atomInfo.kind == Ast.TypeInfoKind.IF then
                  local baseScope = _lune.unwrap( typeId2Scope[atomInfo.baseId])
                  
                  local scope = Ast.Scope.new(parentScope, true, baseScope and {baseScope} or {})
                  
                  local workTypeInfo = Ast.NormalTypeInfo.createClass( atomInfo.kind == Ast.TypeInfoKind.Class, atomInfo.abstructFlag, scope, baseInfo, interfaceList, parentInfo, true, "pub", atomInfo.txt )
                  
                  newTypeInfo = workTypeInfo
                  typeId2Scope[atomInfo.typeId] = scope
                  typeId2TypeInfo[atomInfo.typeId] = workTypeInfo
                  parentScope:addClass( atomInfo.txt, workTypeInfo )
                else 
                  local scope = nil
                  
                  if atomInfo.kind == Ast.TypeInfoKind.Func or atomInfo.kind == Ast.TypeInfoKind.Method then
                    scope = Ast.Scope.new(parentScope, false, {})
                  end
                  local typeInfoKind = _lune.unwrap( Ast.TypeInfoKind:_from( atomInfo.kind ))
                  
                  local mutable = true
                  
                  do
                    local _exp = atomInfo.mutable
                    if _exp ~= nil then
                    
                        if not _exp then
                          mutable = false
                        end
                      end
                  end
                  
                  local workTypeInfo = Ast.NormalTypeInfo.create( atomInfo.abstructFlag, scope, baseInfo, interfaceList, parentInfo, atomInfo.staticFlag, typeInfoKind, atomInfo.txt, itemTypeInfo, argTypeInfo, retTypeInfo, mutable )
                  
                  newTypeInfo = workTypeInfo
                  typeId2TypeInfo[atomInfo.typeId] = workTypeInfo
                  if atomInfo.kind == Ast.TypeInfoKind.Func or atomInfo.kind == Ast.TypeInfoKind.Method then
                    local symbolKind = Ast.SymbolKind.Fun
                    
                    if atomInfo.kind == Ast.TypeInfoKind.Method then
                      symbolKind = Ast.SymbolKind.Mtd
                    end
                    (_lune.unwrap( typeId2Scope[atomInfo.parentId]) ):add( symbolKind, false, atomInfo.kind == Ast.TypeInfoKind.Func, atomInfo.txt, workTypeInfo, atomInfo.accessMode, atomInfo.staticFlag, false, true )
                    typeId2Scope[atomInfo.typeId] = scope
                  end
                end
              end
            end
          else 
            newTypeInfo = Ast.rootScope:getTypeInfo( atomInfo.txt, Ast.rootScope, false )
            if not newTypeInfo then
              for key, val in pairs( atomInfo ) do
                Util.errorLog( string.format( "error: illegal atomInfo %s:%s", key, val) )
              end
            end
            typeId2TypeInfo[atomInfo.typeId] = _lune.unwrap( newTypeInfo)
          end
        end
    end
    
    return _lune.unwrap( newTypeInfo)
  end
  
  for __index, atomInfo in pairs( moduleInfo._typeInfoList ) do
    registTypeInfo( atomInfo )
  end
  for __index, atomInfo in pairs( moduleInfo._typeInfoList ) do
    if atomInfo.children and #atomInfo.children > 0 then
      local scope = _lune.unwrap( typeId2Scope[atomInfo.typeId])
      
      for __index, childId in pairs( atomInfo.children ) do
        local typeInfo = _lune.unwrap( typeId2TypeInfo[childId])
        
        local symbolKind = Ast.SymbolKind.Typ
        
        local addFlag = true
        
        do
          local _switchExp = typeInfo:get_kind()
          if _switchExp == Ast.TypeInfoKind.Func then
            symbolKind = Ast.SymbolKind.Fun
          elseif _switchExp == Ast.TypeInfoKind.Method then
            symbolKind = Ast.SymbolKind.Mtd
          elseif _switchExp == Ast.TypeInfoKind.Class or _switchExp == Ast.TypeInfoKind.Module then
            symbolKind = Ast.SymbolKind.Typ
          elseif _switchExp == Ast.TypeInfoKind.Enum then
            addFlag = false
          end
        end
        
        if addFlag then
          scope:add( symbolKind, false, typeInfo:get_kind() == Ast.TypeInfoKind.Func, typeInfo:getTxt(  ), typeInfo, typeInfo:get_accessMode(), typeInfo:get_staticFlag(), typeInfo:get_mutable(), true )
        end
      end
    end
  end
  for typeId, typeInfo in pairs( typeId2TypeInfo ) do
    newId2OldIdMap[typeInfo:get_typeId(  )] = typeId
  end
  local function registMember( classTypeId )
    local classTypeInfo = _lune.unwrap( typeId2TypeInfo[classTypeId])
    
    do
      local _switchExp = (classTypeInfo:get_kind() )
      if _switchExp == Ast.TypeInfoKind.Class then
        self:pushClass( true, classTypeInfo:get_abstructFlag(), nil, nil, true, classTypeInfo:getTxt(  ), "pub" )
        do
          local _exp = moduleInfo._typeId2ClassInfoMap[classTypeId]
          if _exp ~= nil then
          
              local classInfo = _exp
              
              for fieldName, fieldInfo in pairs( classInfo ) do
                local typeId = fieldInfo['typeId']
                
                local fieldTypeInfo = _lune.unwrap( typeId2TypeInfo[typeId])
                
                self.scope:addMember( fieldName, fieldTypeInfo, (_lune.unwrap( fieldInfo['accessMode']) ), (_lune.unwrapDefault( fieldInfo['staticFlag'], false) ), (_lune.unwrapDefault( fieldInfo['mutable'], false) ) )
              end
            else
          
              self:error( string.format( "not found class -- %d, %s", classTypeId, classTypeInfo:getTxt(  )) )
            end
        end
        
      elseif _switchExp == Ast.TypeInfoKind.Module then
        self:pushModule( true, classTypeInfo:getTxt(  ), classTypeInfo:get_mutable() )
      end
    end
    
    for __index, child in pairs( classTypeInfo:get_children(  ) ) do
      if child:get_kind(  ) == Ast.TypeInfoKind.Class or child:get_kind(  ) == Ast.TypeInfoKind.Module or child:get_kind(  ) == Ast.TypeInfoKind.IF then
        local oldId = newId2OldIdMap[child:get_typeId(  )]
        
        if oldId then
          registMember( _lune.unwrap( oldId) )
        end
      end
    end
    if classTypeInfo:get_kind() == Ast.TypeInfoKind.Class then
      self:popClass(  )
    elseif classTypeInfo:get_kind() == Ast.TypeInfoKind.Module then
      self:popModule(  )
    end
  end
  
  for __index, atomInfo in pairs( moduleInfo._typeInfoList ) do
    if atomInfo.parentId == Ast.rootTypeId and (atomInfo.kind == Ast.TypeInfoKind.Class or atomInfo.kind == Ast.TypeInfoKind.Module or atomInfo.kind == Ast.TypeInfoKind.IF ) then
      registMember( atomInfo.typeId )
    end
  end
  for index, moduleName in pairs( nameList ) do
    local mutable = false
    
    if index == #nameList then
      mutable = moduleInfo._moduleMutable
    end
    self:pushModule( true, moduleName, mutable )
  end
  for varName, varInfo in pairs( moduleInfo._varName2InfoMap ) do
    self.scope:addStaticVar( false, true, varName, _lune.unwrap( typeId2TypeInfo[varInfo['typeId']]), _lune.unwrapDefault( varInfo['mutable'], false) )
  end
  for __index, moduleName in pairs( nameList ) do
    self:popModule(  )
  end
  self.scope = self.moduleScope
  local moduleTypeInfo = _lune.unwrap( typeId2TypeInfo[moduleInfo._moduleTypeId])
  
  self.scope:add( Ast.SymbolKind.Typ, false, false, moduleToken.txt, moduleTypeInfo, "local", true, moduleInfo._moduleMutable, true )
  self:checkToken( nextToken, ";" )
  if self.moduleScope ~= self.scope then
    self:error( "illegal top scope." )
  end
  return Ast.ImportNode.new(token.pos, {Ast.builtinTypeNone}, modulePath, moduleTypeInfo)
end

function TransUnit:analyzeSubfile( token )
  if self.scope ~= self.moduleScope then
    self:error( "'module' must be top scope." )
  end
  local mode = self:getToken(  )
  
  local moduleName = ""
  
  while true do
    local nextToken = self:getToken(  )
    
    if nextToken.txt == ";" then
      break
    end
    if moduleName == "" then
      moduleName = nextToken.txt
    else 
      moduleName = string.format( "%s%s", moduleName, nextToken.txt)
    end
  end
  if moduleName == "" then
    self:addErrMess( token.pos, "illegal subfile" )
  else 
    if mode.txt == "use" then
      if _luneScript.searchModule( moduleName ) then
        table.insert( self.subfileList, moduleName )
      else 
        self:addErrMess( token.pos, string.format( "not found subfile -- %s", moduleName) )
      end
    elseif mode.txt == "owner" then
      if self.moduleName ~= moduleName then
        self:addErrMess( token.pos, string.format( "illegal owner module -- %s, %s", moduleName, self.moduleName) )
      end
    else 
      self:addErrMess( mode.pos, string.format( "illegal module mode -- %s", mode.txt) )
    end
  end
  return Ast.SubfileNode.new(token.pos, {Ast.builtinTypeNone})
end

function TransUnit:analyzeIf( token )
  local nextToken, continueFlag = self:getContinueToken(  )
  
  if continueFlag and nextToken.txt == "!" then
    return self:analyzeIfUnwrap( token )
  end
  self:pushback(  )
  local list = {}
  
  table.insert( list, Ast.IfStmtInfo.new("if", self:analyzeExp( false ), self:analyzeBlock( "if" )) )
  nextToken = self:getToken( true )
  if nextToken.txt == "elseif" then
    while nextToken.txt == "elseif" do
      table.insert( list, Ast.IfStmtInfo.new("elseif", self:analyzeExp( false ), self:analyzeBlock( "elseif" )) )
      nextToken = self:getToken( true )
    end
  end
  if nextToken.txt == "else" then
    table.insert( list, Ast.IfStmtInfo.new("else", Ast.NoneNode.new(nextToken.pos, {Ast.builtinTypeNone}), self:analyzeBlock( "else" )) )
  else 
    self:pushback(  )
  end
  return Ast.IfNode.new(token.pos, {Ast.builtinTypeNone}, list)
end

function TransUnit:analyzeSwitch( firstToken )
  local exp = self:analyzeExp( false )
  
  self:checkNextToken( "{" )
  local caseList = {}
  
  local nextToken = self:getToken(  )
  
  while (nextToken.txt == "case" ) do
    self:checkToken( nextToken, "case" )
    local condexpList = self:analyzeExpList( false )
    
    local condBock = self:analyzeBlock( "switch" )
    
    table.insert( caseList, Ast.CaseInfo.new(condexpList, condBock) )
    nextToken = self:getToken(  )
  end
  local defaultBlock = nil
  
  if nextToken.txt == "default" then
    defaultBlock = self:analyzeBlock( "default" )
  else 
    self:pushback(  )
  end
  self:checkNextToken( "}" )
  return Ast.SwitchNode.new(firstToken.pos, {Ast.builtinTypeNone}, exp, caseList, defaultBlock)
end

function TransUnit:analyzeWhile( token )
  return Ast.WhileNode.new(token.pos, {Ast.builtinTypeNone}, self:analyzeExp( false ), self:analyzeBlock( "while" ))
end

function TransUnit:analyzeRepeat( token )
  local scope = self:pushScope( false )
  
  local node = Ast.RepeatNode.new(token.pos, {Ast.builtinTypeNone}, self:analyzeBlock( "repeat", scope ), self:analyzeExp( false ))
  
  self:popScope(  )
  self:checkNextToken( ";" )
  return node
end

function TransUnit:analyzeFor( firstToken )
  local scope = self:pushScope( false )
  
  local val = self:getToken(  )
  
  if val.kind ~= Parser.TokenKind.Symb then
    self:error( "not symbol" )
  end
  self:checkNextToken( "=" )
  local exp1 = self:analyzeExp( false )
  
  if not exp1:get_expType():equals( Ast.builtinTypeInt ) then
    self:addErrMess( exp1:get_pos(), string.format( "exp1 is not int -- %s", exp1:get_expType():getTxt(  )) )
  end
  self.scope:addLocalVar( false, true, val.txt, exp1:get_expType(), false )
  self:checkNextToken( "," )
  local exp2 = self:analyzeExp( false )
  
  if not exp2:get_expType():equals( Ast.builtinTypeInt ) then
    self:addErrMess( exp2:get_pos(), string.format( "exp2 is not int -- %s", exp2:get_expType():getTxt(  )) )
  end
  local token = self:getToken(  )
  
  local exp3 = nil
  
  if token.txt == "," then
    exp3 = self:analyzeExp( false )
    do
      local _exp = exp3
      if _exp ~= nil then
      
          if not _exp:get_expType():equals( Ast.builtinTypeInt ) then
            self:addErrMess( _exp:get_pos(), string.format( "exp is not int -- %s", _exp:get_expType():getTxt(  )) )
          end
        end
    end
    
  else 
    self:pushback(  )
  end
  local node = Ast.ForNode.new(firstToken.pos, {Ast.builtinTypeNone}, self:analyzeBlock( "for", scope ), val, exp1, exp2, exp3)
  
  self:popScope(  )
  return node
end

function TransUnit:analyzeApply( token )
  local scope = self:pushScope( false )
  
  local varList = {}
  
  local nextToken = Parser.getEofToken(  )
  
  repeat 
    local var = self:getSymbolToken(  )
    
    if var.kind ~= Parser.TokenKind.Symb then
      self:error( "illegal symbol" )
    end
    table.insert( varList, var )
    nextToken = self:getToken(  )
    scope:addLocalVar( false, true, var.txt, Ast.builtinTypeStem, false )
  until nextToken.txt ~= ","
  self:checkToken( nextToken, "of" )
  local exp = self:analyzeExp( false )
  
  if exp:get_kind() ~= Ast.nodeKindExpCall then
    self:error( "not call" )
  end
  local block = self:analyzeBlock( "apply", scope )
  
  self:popScope(  )
  return Ast.ApplyNode.new(token.pos, {Ast.builtinTypeNone}, varList, exp, block)
end

function TransUnit:analyzeForeach( token, sortFlag )
  local scope = self:pushScope( false )
  
  local valSymbol = Parser.getEofToken(  )
  
  local keySymbol = nil
  
  local nextToken = Parser.getEofToken(  )
  
  for index = 1, 2 do
    local sym = self:getToken(  )
    
    if sym.kind ~= Parser.TokenKind.Symb then
      self:error( "illegal symbol" )
    end
    if index == 1 then
      valSymbol = sym
    else 
      keySymbol = sym
    end
    nextToken = self:getToken(  )
    if nextToken.txt ~= "," then
      break
    end
  end
  self:checkToken( nextToken, "in" )
  local exp = self:analyzeExp( false )
  
  if not exp:get_expType() then
    self:error( string.format( "unknown type of exp -- %d:%d", token.pos.lineNo, token.pos.column) )
  else 
    local itemTypeInfoList = exp:get_expType():get_itemTypeInfoList(  )
    
    if exp:get_expType():get_kind(  ) == Ast.TypeInfoKind.Map then
      self.scope:addLocalVar( false, true, valSymbol.txt, itemTypeInfoList[2], false )
      do
        local _exp = keySymbol
        if _exp ~= nil then
        
            self.scope:addLocalVar( false, true, _exp.txt, itemTypeInfoList[1], false )
          end
      end
      
    elseif exp:get_expType():get_kind(  ) == Ast.TypeInfoKind.List or exp:get_expType():get_kind(  ) == Ast.TypeInfoKind.Array then
      self.scope:addLocalVar( false, true, valSymbol.txt, itemTypeInfoList[1], false )
      do
        local _exp = keySymbol
        if _exp ~= nil then
        
            self.scope:addLocalVar( false, false, _exp.txt, Ast.builtinTypeInt, false )
          else
        
            self.scope:addLocalVar( false, false, "__index", Ast.builtinTypeInt, false )
          end
      end
      
    else 
      self:error( string.format( "unknown kind type of exp for foreach-- %d:%d", exp:get_pos().lineNo, exp:get_pos().column) )
    end
  end
  local block = self:analyzeBlock( "foreach", scope )
  
  self:popScope(  )
  if sortFlag then
    return Ast.ForsortNode.new(token.pos, {Ast.builtinTypeNone}, valSymbol, keySymbol, exp, block, sortFlag)
  else 
    return Ast.ForeachNode.new(token.pos, {Ast.builtinTypeNone}, valSymbol, keySymbol, exp, block)
  end
end

function TransUnit:analyzeProvide( firstToken )
  local val = self:analyzeExp( true )
  
  self:checkNextToken( ";" )
  do
    local _switchExp = val:get_kind()
    if _switchExp == Ast.nodeKindExpRef then
      local expRefNode = val
      
    end
  end
  
  local node = Ast.ProvideNode.new(firstToken.pos, {Ast.builtinTypeNone}, val)
  
  if self.provideNode then
    self:addErrMess( firstToken.pos, "multiple provide" )
  end
  self.provideNode = node
  if node:get_val():get_kind() == Ast.nodeKindExpRef then
    local expRefNode = node:get_val()
    
    do
      local __sorted = {}
      local __map = self.moduleScope:get_symbol2TypeInfoMap()
      for __key in pairs( __map ) do
        table.insert( __sorted, __key )
      end
      table.sort( __sorted )
      for __index, symbol in ipairs( __sorted ) do
        symbolInfo = __map[ symbol ]
        do
          if expRefNode:get_symbolInfo():get_symbolId() == symbolInfo:get_symbolId() then
            if symbolInfo:get_accessMode() ~= "pub" then
              self:addErrMess( firstToken.pos, string.format( "provide variable must be 'pub'.  -- %s", symbolInfo:get_accessMode()) )
            end
          elseif symbolInfo:get_accessMode() == "pub" then
            self:addErrMess( firstToken.pos, string.format( "variable (%s) can't set 'pub'.", symbolInfo:get_name()) )
          end
        end
      end
    end
    
  end
  return node
end

function TransUnit:analyzeRefType( accessMode, allowDDD )
  local firstToken = self:getToken(  )
  
  local token = firstToken
  
  local refFlag = false
  
  if token.txt == "&" then
    refFlag = true
    token = self:getToken(  )
  end
  local mutFlag = false
  
  if token.txt == "mut" then
    mutFlag = true
    token = self:getToken(  )
  end
  local typeInfo = Ast.builtinTypeStem_
  
  self:checkSymbol( token )
  local name = self:analyzeExpSymbol( firstToken, token, "symbol", nil, true )
  
  typeInfo = name:get_expType()
  local continueToken, continueFlag = self:getContinueToken(  )
  
  token = continueToken
  if continueFlag and token.txt == "!" then
    typeInfo = _lune.unwrap( typeInfo:get_nilableTypeInfo(  ))
    token = self:getToken(  )
  end
  local arrayMode = "no"
  
  while true do
    if token.txt == '[' or token.txt == '[@' then
      if token.txt == '[' then
        arrayMode = "list"
        typeInfo = Ast.NormalTypeInfo.createList( accessMode, self:getCurrentClass(  ), {typeInfo} )
      else 
        arrayMode = "array"
        typeInfo = Ast.NormalTypeInfo.createArray( accessMode, self:getCurrentClass(  ), {typeInfo} )
      end
      token = self:getToken(  )
      if token.txt ~= ']' then
        self:pushback(  )
        self:checkNextToken( ']' )
      end
    elseif token.txt == "<" then
      local genericList = {}
      
      local nextToken = Parser.getEofToken(  )
      
      repeat 
        local typeExp = self:analyzeRefType( accessMode, false )
        
        table.insert( genericList, typeExp:get_expType() )
        nextToken = self:getToken(  )
      until nextToken.txt ~= ","
      self:checkToken( nextToken, '>' )
      if typeInfo:get_kind() == Ast.TypeInfoKind.Map then
        typeInfo = Ast.NormalTypeInfo.createMap( accessMode, self:getCurrentClass(  ), genericList[1] or Ast.builtinTypeStem, genericList[2] or Ast.builtinTypeStem )
      elseif typeInfo:get_kind() == Ast.TypeInfoKind.List then
        typeInfo = Ast.NormalTypeInfo.createList( accessMode, self:getCurrentClass(  ), {genericList[1]} or {Ast.builtinTypeStem} )
      else 
        self:error( string.format( "not support generic: %s", typeInfo:getTxt(  ) ) )
      end
    else 
      self:pushback(  )
      break
    end
    token = self:getToken(  )
  end
  if token.txt == "!" then
    typeInfo = _lune.unwrap( typeInfo:get_nilableTypeInfo(  ))
    token = self:getToken(  )
  end
  if not allowDDD and typeInfo:equals( Ast.builtinTypeDDD ) then
    self:addErrMess( firstToken.pos, string.format( "invalid type. -- '%s'", typeInfo:getTxt(  )) )
  end
  if refFlag then
    typeInfo = self:createModifier( typeInfo, false )
  end
  return Ast.RefTypeNode.new(firstToken.pos, {typeInfo}, name, refFlag, mutFlag, arrayMode)
end

function TransUnit:analyzeDeclArgList( accessMode, argList )
  local nextToken = Parser.noneToken
  
  repeat 
    nextToken = self:getToken(  )
    if nextToken.txt == ")" then
      break
    end
    local mutable = false
    
    if nextToken.txt == "mut" then
      mutable = true
      nextToken = self:getToken(  )
    end
    local argName = nextToken
    
    if argName.txt == "..." then
      table.insert( argList, Ast.DeclArgDDDNode.new(argName.pos, {Ast.builtinTypeDDD}) )
      self.scope:addLocalVar( false, true, argName.txt, Ast.builtinTypeDDD, false )
    else 
      argName = self:checkSymbol( argName )
      if self.scope:getSymbolTypeInfo( argName.txt, self.scope, self.moduleScope ) then
        self:addErrMess( argName.pos, string.format( "shadowing variable -- %s", argName.txt) )
      end
      self:checkNextToken( ":" )
      local refType = self:analyzeRefType( accessMode, false )
      
      local arg = Ast.DeclArgNode.new(argName.pos, refType:get_expTypeList(), argName, refType)
      
      self.scope:addLocalVar( false, true, argName.txt, refType:get_expType(), mutable )
      table.insert( argList, arg )
    end
    nextToken = self:getToken(  )
  until nextToken.txt ~= ","
  self:checkToken( nextToken, ")" )
  return nextToken
end

local ASTInfo = {}
_moduleObj.ASTInfo = ASTInfo
function ASTInfo.new( node, moduleTypeInfo )
  local obj = {}
  setmetatable( obj, { __index = ASTInfo } )
  if obj.__init then
    obj:__init( node, moduleTypeInfo )
  end        
  return obj 
end         
function ASTInfo:__init( node, moduleTypeInfo ) 

self.node = node
  self.moduleTypeInfo = moduleTypeInfo
  end
function ASTInfo:get_node()       
  return self.node         
end
function ASTInfo:get_moduleTypeInfo()       
  return self.moduleTypeInfo         
end
do
  end

function TransUnit:createAST( parser, macroFlag, moduleName )
  self.moduleName = _lune.unwrapDefault( moduleName, "")
  self:registBuiltInScope(  )
  local moduleTypeInfo = Ast.typeInfoRoot
  
  do
    local _exp = moduleName
    if _exp ~= nil then
    
        for txt in string.gmatch( _exp, '[^%.]+' ) do
          moduleTypeInfo = _lune.unwrap( self:pushModule( false, txt, true ))
        end
      end
  end
  
  self.moduleScope = self.scope
  self.parser = parser
  local ast = nil
  
  local lastStatement = nil
  
  if macroFlag then
    ast = self:analyzeBlock( "macro" )
  else 
    local children = {}
    
    lastStatement = self:analyzeStatementList( children )
    local token = self:getTokenNoErr(  )
    
    if token ~= Parser.getEofToken(  ) then
      Util.err( string.format( "unknown:%d:%d:(%s) %s", token.pos.lineNo, token.pos.column, Parser.getKindTxt( token.kind ), token.txt) )
    end
    for __index, subModule in pairs( self.subfileList ) do
      local file = _luneScript.searchModule( subModule )
      
          if  nil == file then
            local _file = file
            
            self:error( string.format( "not found subfile -- %s", subModule) )
          end
        
      if self.scope ~= self.moduleScope then
        self:error( "scope does not close" )
      end
      local subParser = Parser.StreamParser.create( file, false, subModule )
      
          if  nil == subParser then
            local _subParser = subParser
            
            self:error( string.format( "open error -- %s", file) )
          end
        
      self.parser = subParser
      lastStatement = self:analyzeStatementListSubfile( children )
      token = self:getTokenNoErr(  )
      if token ~= Parser.getEofToken(  ) then
        Util.err( string.format( "unknown:%d:%d:(%s) %s", token.pos.lineNo, token.pos.column, Parser.getKindTxt( token.kind ), token.txt) )
      end
    end
    local luneHelperInfo = Ast.LuneHelperInfo.new(self.useNilAccess, self.useUnwrapExp)
    
    local rootNode = Ast.RootNode.new(Parser.Position.new(0, 0), {Ast.builtinTypeNone}, children, nil, luneHelperInfo, self.typeId2ClassMap)
    
    ast = rootNode
    do
      local _exp = self.provideNode
      if _exp ~= nil then
      
          if lastStatement ~= _exp then
            self:addErrMess( _exp:get_pos(), "'provide' must be last." )
          end
          rootNode:set_provide( _exp )
        end
    end
    
  end
  do
    local _exp = moduleName
    if _exp ~= nil then
    
        for txt in string.gmatch( _exp, '[^%.]+' ) do
          self:popModule(  )
        end
      end
  end
  
  if #self.errMessList > 0 then
    for __index, mess in pairs( self.errMessList ) do
      Util.errorLog( mess )
    end
    Util.err( "has error" )
  end
  if self.analyzeMode == "diag" or self.analyzeMode == "comp" then
    os.exit( 0 )
  end
  return ASTInfo.new(_lune.unwrap( ast), moduleTypeInfo)
end

function TransUnit:analyzeDeclMacro( accessMode, firstToken )
  local nameToken = self:getToken(  )
  
  self:checkNextToken( "(" )
  local scope = self:pushScope( false )
  
  local workArgList = {}
  
  local argList = {}
  
  local nextToken = self:analyzeDeclArgList( accessMode, workArgList )
  
  local argTypeList = {}
  
  for index, argNode in pairs( workArgList ) do
    if argNode:get_kind() == Ast.nodeKindDeclArg then
      table.insert( argList, argNode )
    else 
      self:error( "macro argument can not use '...'." )
    end
    local argType = argNode:get_expType()
    
    table.insert( argTypeList, argType )
  end
  self:checkNextToken( "{" )
  nextToken = self:getToken(  )
  local ast = nil
  
  if nextToken.txt == "{" then
    local parser = Parser.WrapParser.new(self.parser, string.format( "decl macro %s", nameToken.txt))
    
    self.macroScope = scope
    local bakParser = self.parser
    
    self.parser = parser
    local stmtList = {}
    
    self:analyzeStatementList( stmtList, "}" )
    self:checkNextToken( "}" )
    self.parser = bakParser
    self.macroScope = nil
    ast = Ast.BlockNode.new(firstToken.pos, {Ast.builtinTypeNone}, "macro", stmtList)
  else 
    self:pushback(  )
  end
  self:popScope(  )
  local tokenList = {}
  
  local braceCount = 0
  
  while true do
    nextToken = self:getToken(  )
    if nextToken.txt == "{" then
      braceCount = braceCount + 1
    elseif nextToken.txt == "}" then
      if braceCount == 0 then
        break
      end
      braceCount = braceCount - 1
    end
    table.insert( tokenList, nextToken )
  end
  local typeInfo = Ast.NormalTypeInfo.createFunc( false, false, scope, Ast.TypeInfoKind.Macro, self:getCurrentNamespaceTypeInfo(  ), false, false, false, accessMode, nameToken.txt, argTypeList )
  
  self.scope:addLocalVar( false, false, nameToken.txt, typeInfo, false )
  local declMacroInfo = Ast.DeclMacroInfo.new(nameToken, argList, ast, tokenList)
  
  local node = Ast.DeclMacroNode.new(firstToken.pos, {typeInfo}, declMacroInfo)
  
  local macroObj = self.macroEval:eval( node )
  
  self.typeId2MacroInfo[typeInfo:get_typeId(  )] = Ast.MacroInfo.new(macroObj, declMacroInfo, self.symbol2ValueMapForMacro)
  self.symbol2ValueMapForMacro = {}
  return node
end

function TransUnit:analyzePushClass( classFlag, abstructFlag, firstToken, name, accessMode )
  local nextToken = self:getToken(  )
  
  local baseRef = nil
  
  local interfaceList = {}
  
  if nextToken.txt == "extend" then
    nextToken = self:getToken(  )
    if nextToken.txt ~= "(" then
      self:pushback(  )
      baseRef = self:analyzeRefType( accessMode, false )
      nextToken = self:getToken(  )
    end
    if nextToken.txt == "(" then
      while true do
        nextToken = self:getToken(  )
        if nextToken.txt == ")" then
          break
        end
        self:pushback(  )
        local ifType = self:analyzeRefType( accessMode, false )
        
        if ifType:get_expType():get_kind() ~= Ast.TypeInfoKind.IF then
          self:error( string.format( "%s is not interface -- %d", ifType:get_expType():getTxt(  ), ifType:get_expType():get_kind()) )
        end
        table.insert( interfaceList, ifType:get_expType() )
        nextToken = self:getToken(  )
        if nextToken.txt ~= "," then
          if nextToken.txt == ")" then
            break
          end
          self:error( "illegal token" )
        end
      end
      nextToken = self:getToken(  )
    end
  end
  local typeInfo = nil
  
  do
    local _exp = baseRef
    if _exp ~= nil then
    
        local baseTypeInfo = _exp:get_expType(  )
        
        typeInfo = baseTypeInfo
        local initTypeInfo = _lune.nilacc( baseTypeInfo:get_scope(), 'getTypeInfoChild', 'callmtd' , "__init" )
        
            if  nil == initTypeInfo then
              local _initTypeInfo = initTypeInfo
              
            else
              
                if initTypeInfo:get_accessMode() == "pri" then
                  self:addErrMess( firstToken.pos, "The access mode of '__init' is 'pri'." )
                end
              end
          
      end
  end
  
  local classTypeInfo = self:pushClass( classFlag, abstructFlag, typeInfo, interfaceList, false, name.txt, accessMode )
  
  return nextToken, classTypeInfo
end

function TransUnit:analyzeDeclProto( accessMode, firstToken )
  local nextToken = self:getToken(  )
  
  local abstructFlag = false
  
  if nextToken.txt == "abstruct" then
    abstructFlag = true
    nextToken = self:getToken(  )
  end
  if nextToken.txt == "class" or nextToken.txt == "interface" then
    local name = self:getSymbolToken(  )
    
    nextToken = self:analyzePushClass( nextToken.txt ~= "interface", abstructFlag, firstToken, name, accessMode )
    self:popClass(  )
    self:checkToken( nextToken, ";" )
  else 
    self:error( "illegal proto" )
  end
  return self:createNoneNode( firstToken.pos )
end

function TransUnit:analyzeDeclEnum( accessMode, firstToken )
  local name = self:getSymbolToken(  )
  
  self:checkNextToken( "{" )
  local valueList = {}
  
  local valueName2Info = {}
  
  local scope = self:pushScope( false )
  
  local enumTypeInfo = Ast.rootTypeInfo
  
  local nextToken = self:getToken(  )
  
  local number = 0.0
  
  local prevValTypeInfo = Ast.rootTypeInfo
  
  local valTypeInfo = Ast.rootTypeInfo
  
  while nextToken.txt ~= "}" do
    local valName = nextToken
    
    nextToken = self:getToken(  )
    local enumVal = number
    
    do
      local _switchExp = (prevValTypeInfo )
      if _switchExp == Ast.builtinTypeReal then
      elseif _switchExp == Ast.builtinTypeInt or _switchExp == Ast.rootTypeInfo then
        enumVal = math.floor(number)
      end
    end
    
    if nextToken.txt == "=" then
      local exp = self:analyzeExp( false )
      
      local valList, typeInfoList = exp:getLiteral(  )
      
      if #valList ~= 1 or #typeInfoList ~= 1 then
        self:error( string.format( "illegal enum val -- %d %d", #valList, #typeInfoList) )
      end
      valTypeInfo = typeInfoList[1]
      do
        local _switchExp = (valTypeInfo )
        if _switchExp == Ast.builtinTypeString then
          enumVal = (_lune.unwrap( valList[1]) )
        elseif _switchExp == Ast.builtinTypeInt then
          local val = math.floor((_lune.unwrap( valList[1]) ))
          
          enumVal = val
          number = val
        elseif _switchExp == Ast.builtinTypeReal then
          number = (_lune.unwrap( valList[1]) )
          enumVal = number
        else 
          self:error( string.format( "illegal enum val type -- %s", valTypeInfo:getTxt(  )) )
        end
      end
      
      nextToken = self:getToken(  )
    else 
      do
        local _switchExp = (prevValTypeInfo )
        if _switchExp == Ast.rootTypeInfo then
          valTypeInfo = Ast.builtinTypeInt
        elseif _switchExp == Ast.builtinTypeInt or _switchExp == Ast.builtinTypeReal then
          valTypeInfo = prevValTypeInfo
        else 
          self:addErrMess( valName.pos, string.format( "illegal enum val type -- %s", valTypeInfo:getTxt(  )) )
        end
      end
      
    end
    if prevValTypeInfo ~= Ast.rootTypeInfo and prevValTypeInfo ~= valTypeInfo then
      self:addErrMess( valName.pos, string.format( "multiple enum val type. %s, %s", valTypeInfo:getTxt(  ), prevValTypeInfo:getTxt(  )) )
    end
    prevValTypeInfo = valTypeInfo
    if enumTypeInfo == Ast.rootTypeInfo then
      enumTypeInfo = Ast.NormalTypeInfo.createEnum( scope, self:getCurrentNamespaceTypeInfo(  ), false, accessMode, name.txt, valTypeInfo, valueName2Info )
    end
    scope:addEnumVal( valName.txt, enumTypeInfo )
    local enumValInfo = Ast.EnumValInfo.new(valName.txt, enumVal)
    
    table.insert( valueList, valName )
    valueName2Info[valName.txt] = enumValInfo
    if nextToken.txt == "}" then
      break
    end
    self:checkToken( nextToken, "," )
    nextToken = self:getToken(  )
    number = number + 1
  end
  if enumTypeInfo == Ast.rootTypeInfo then
    enumTypeInfo = Ast.NormalTypeInfo.createEnum( scope, self:getCurrentNamespaceTypeInfo(  ), false, accessMode, name.txt, Ast.builtinTypeNone, valueName2Info )
  end
  self:popScope(  )
  self.scope:addEnum( accessMode, name.txt, enumTypeInfo )
  return Ast.DeclEnumNode.new(firstToken.pos, {enumTypeInfo}, accessMode, name, valueList, scope)
end

function TransUnit:analyzeDecl( accessMode, staticFlag, firstToken, token )
  if not staticFlag then
    if token.txt == "static" then
      staticFlag = true
      token = self:getToken(  )
    end
  end
  local overrideFlag = false
  
  if token.txt == "override" then
    overrideFlag = true
    token = self:getToken(  )
  end
  local abstructFlag = false
  
  if token.txt == "abstruct" then
    abstructFlag = true
    token = self:getToken(  )
  end
  if token.txt == "let" then
    return self:analyzeDeclVar( "let", accessMode, firstToken )
  elseif token.txt == "fn" then
    return self:analyzeDeclFunc( false, abstructFlag, overrideFlag, accessMode, staticFlag, nil, firstToken, nil )
  elseif token.txt == "abstruct" then
    self:checkNextToken( "class" )
    return self:analyzeDeclClass( true, accessMode, firstToken, "class" )
  elseif token.txt == "class" then
    return self:analyzeDeclClass( false, accessMode, firstToken, "class" )
  elseif token.txt == "interface" then
    return self:analyzeDeclClass( true, accessMode, firstToken, "interface" )
  elseif token.txt == "module" then
    return self:analyzeDeclClass( false, accessMode, firstToken, "module" )
  elseif token.txt == "proto" then
    return self:analyzeDeclProto( accessMode, firstToken )
  elseif token.txt == "macro" then
    return self:analyzeDeclMacro( accessMode, firstToken )
  elseif token.txt == "enum" then
    return self:analyzeDeclEnum( accessMode, firstToken )
  end
  return nil
end

function TransUnit:analyzeDeclMember( accessMode, staticFlag, firstToken )
  local nextToken = self:getToken(  )
  
  local mutable = false
  
  if nextToken.txt == "mut" then
    mutable = true
    nextToken = self:getToken(  )
  end
  local varName = self:checkSymbol( nextToken )
  
  local token = self:getToken(  )
  
  local refType = self:analyzeRefType( accessMode, false )
  
  token = self:getToken(  )
  local getterMode = "none"
  
  local getterMutable = true
  
  local setterMode = "none"
  
  if token.txt == "{" then
    local function analyzeAccessorMode(  )
      local mode = "none"
      
      local workToken = self:getToken(  )
      
      do
        local _switchExp = workToken.txt
        if _switchExp == "pub" or _switchExp == "pri" or _switchExp == "pro" then
          mode = workToken.txt
          workToken = self:getToken(  )
          if workToken.txt == "&" then
            getterMutable = false
            workToken = self:getToken(  )
          end
        end
      end
      
      return mode, workToken
    end
    
    getterMode, nextToken = analyzeAccessorMode(  )
    if nextToken.txt == "," then
      setterMode, nextToken = analyzeAccessorMode(  )
    end
    self:checkToken( nextToken, "}" )
    token = self:getToken(  )
  end
  self:checkToken( token, ";" )
  local typeInfo = refType:get_expType()
  
  if typeInfo:get_mutable() and not mutable then
    typeInfo = self:createModifier( typeInfo, false )
  end
  local symbolInfo = self.scope:addMember( varName.txt, typeInfo, accessMode, staticFlag, mutable )
  
  return Ast.DeclMemberNode.new(firstToken.pos, {typeInfo}, varName, refType, symbolInfo, staticFlag, accessMode, getterMutable, getterMode, setterMode)
end

function TransUnit:analyzeDeclMethod( moduleFlag, abstructFlag, overrideFlag, accessMode, staticFlag, className, firstToken, name )
  local node = self:analyzeDeclFunc( moduleFlag, abstructFlag, overrideFlag, accessMode, staticFlag, className, name, name )
  
  return node
end

function TransUnit:analyzeClassBody( classAccessMode, firstToken, mode, classTypeInfo, name, moduleName, nextToken )
  local memberName2Node = {}
  
  local fieldList = {}
  
  local memberList = {}
  
  local methodNameSet = {}
  
  local initStmtList = {}
  
  local advertiseList = {}
  
  local trustList = {}
  
  local node = Ast.DeclClassNode.new(firstToken.pos, {classTypeInfo}, classAccessMode, name, fieldList, moduleName, memberList, self.scope, initStmtList, advertiseList, trustList, {})
  
  self.typeInfo2ClassNode[classTypeInfo] = node
  local declCtorNode = nil
  
  while true do
    local token = self:getToken(  )
    
    if token.txt == "}" then
      break
    end
    local accessMode = "pri"
    
    if token.txt == "pub" or token.txt == "pro" or token.txt == "pri" or token.txt == "global" then
      accessMode = token.txt
      token = self:getToken(  )
    end
    local staticFlag = false
    
    if token.txt == "static" then
      staticFlag = true
      token = self:getToken(  )
    end
    local overrideFlag = false
    
    if token.txt == "override" then
      overrideFlag = true
      token = self:getToken(  )
    end
    local abstructFlag = false
    
    if token.txt == "abstructFlag" then
      abstructFlag = true
      token = self:getToken(  )
    end
    if token.txt == "let" then
      if mode == "interface" then
        self:error( "interface can not have member" )
      end
      if not staticFlag and declCtorNode then
        self:addErrMess( token.pos, "member can't declare after '__init' method." )
      end
      local memberNode = self:analyzeDeclMember( accessMode, staticFlag, token )
      
      table.insert( fieldList, memberNode )
      table.insert( memberList, memberNode )
      memberName2Node[memberNode:get_name().txt] = memberNode
    elseif token.txt == "fn" then
      local nameToken = self:getToken(  )
      
      local methodNode = self:analyzeDeclMethod( mode == "module", abstructFlag, overrideFlag, accessMode, staticFlag, name, token, nameToken )
      
      table.insert( fieldList, methodNode )
      methodNameSet[nameToken.txt] = true
      if nameToken.txt == "__init" then
        declCtorNode = methodNode
      end
    elseif token.txt == "__init" then
      if mode ~= "class" then
        self:error( string.format( "%s can not have __init method", mode) )
      end
      for symbolName, symbolInfo in pairs( self.scope:get_symbol2TypeInfoMap() ) do
        if symbolInfo:get_staticFlag() then
          symbolInfo:set_hasValueFlag( false )
        end
      end
      self:checkNextToken( "{" )
      self:analyzeStatementList( initStmtList, "}" )
      self:checkNextToken( "}" )
    elseif token.txt == "advertise" then
      local memberToken = self:getSymbolToken(  )
      
      nextToken = self:getToken(  )
      local prefix = ""
      
      if nextToken.txt ~= ";" and nextToken.txt ~= "{" then
        prefix = nextToken.txt
        nextToken = self:getToken(  )
      end
      self:checkToken( nextToken, ";" )
      local memberNode = memberName2Node[memberToken.txt]
      
          if  nil == memberNode then
            local _memberNode = memberNode
            
            self:error( string.format( "not found member -- %s", memberToken.txt) )
          end
        
      table.insert( advertiseList, Ast.AdvertiseInfo.new(memberNode, prefix) )
    elseif token.txt == ";" then
    else 
      self:error( "illegal field" )
    end
  end
  do
    local _exp = declCtorNode
    if _exp ~= nil then
    
        for memberName, memberNode in pairs( memberName2Node ) do
          if not memberNode:get_staticFlag() then
            local symbolInfo = _lune.unwrap( self.scope:getSymbolInfoChild( memberName ))
            
            local typeInfo = symbolInfo:get_typeInfo()
            
            if not symbolInfo:get_hasValueFlag() and not typeInfo:get_nilable() then
              self:addErrMess( _exp:get_pos(), string.format( "does not set member -- %s %s", memberName, symbolInfo:get_symbolId()) )
            end
          end
        end
      end
  end
  
  return node, nextToken, methodNameSet
end

function TransUnit:analyzeDeclClass( classAbstructFlag, classAccessMode, firstToken, mode )
  local name = self:getSymbolToken(  )
  
  local moduleName = nil
  
  if mode == "module" then
    self:checkNextToken( "require" )
    moduleName = self:getToken(  )
  end
  local nextToken, classTypeInfo = self:analyzePushClass( mode ~= "interface", classAbstructFlag, firstToken, name, classAccessMode )
  
  self:checkToken( nextToken, "{" )
  local node, workNextToken, methodNameSet = self:analyzeClassBody( classAccessMode, firstToken, mode, classTypeInfo, name, moduleName, nextToken )
  
  nextToken = workNextToken
  local parentInfo = classTypeInfo
  
  local memberTypeList = {}
  
  for __index, memberNode in pairs( node:get_memberList() ) do
    local memberType = memberNode:get_expType()
    
    if not memberNode:get_staticFlag() then
      table.insert( memberTypeList, memberType )
    end
    local memberName = memberNode:get_name()
    
    local getterName = "get_" .. memberName.txt
    
    local accessMode = memberNode:get_getterMode()
    
    if accessMode ~= "none" and not self.scope:getTypeInfoChild( getterName ) then
      local mutable = memberNode:get_getterMutable()
      
      local getterMemberType = memberType
      
      if memberType:get_mutable() and not mutable then
        getterMemberType = self:createModifier( memberType, false )
      end
      local retTypeInfo = Ast.NormalTypeInfo.createFunc( false, false, self:pushScope( false ), Ast.TypeInfoKind.Method, parentInfo, true, false, memberNode:get_staticFlag(), accessMode, getterName, {}, {getterMemberType} )
      
      self:popScope(  )
      self.scope:addMethod( retTypeInfo, accessMode, memberNode:get_staticFlag(), false )
      methodNameSet[getterName] = true
    end
    local setterName = "set_" .. memberName.txt
    
    accessMode = memberNode:get_setterMode()
    if memberNode:get_setterMode() ~= "none" and not self.scope:getTypeInfoChild( setterName ) then
      self.scope:addMethod( Ast.NormalTypeInfo.createFunc( false, false, self:pushScope( false ), Ast.TypeInfoKind.Method, parentInfo, true, false, memberNode:get_staticFlag(), accessMode, setterName, {memberType}, nil, true ), accessMode, memberNode:get_staticFlag(), true )
      self:popScope(  )
      methodNameSet[setterName] = true
    end
  end
  if not self.scope:getTypeInfoChild( "__init" ) then
    if classTypeInfo:get_baseTypeInfo() ~= Ast.rootTypeInfo then
      local superScope = _lune.unwrap( classTypeInfo:get_baseTypeInfo():get_scope())
      
      local superTypeInfo = _lune.unwrap( superScope:getTypeInfoChild( "__init" ))
      
      for __index, argType in pairs( superTypeInfo:get_argTypeInfoList() ) do
        if not argType:get_nilable() then
          self:addErrMess( firstToken.pos, "not found '__init' decl." )
        end
      end
    end
    local initTypeInfo = Ast.NormalTypeInfo.createFunc( false, false, self:pushScope( false ), Ast.TypeInfoKind.Method, parentInfo, true, false, false, "pub", "__init", memberTypeList, {} )
    
    self:popScope(  )
    self.scope:addMethod( initTypeInfo, "pub", false, false )
    methodNameSet["__init"] = true
    for __index, memberNode in pairs( node:get_memberList() ) do
      if not memberNode:get_staticFlag() then
        memberNode:get_symbolInfo():set_hasValueFlag( true )
      end
    end
  end
  for __index, advertiseInfo in pairs( node:get_advertiseList() ) do
    local memberType = advertiseInfo:get_member():get_expType()
    
    do
      local _switchExp = memberType:get_kind()
      if _switchExp == Ast.TypeInfoKind.Class or _switchExp == Ast.TypeInfoKind.IF then
        for __index, child in pairs( memberType:get_children() ) do
          if child:get_kind() == Ast.TypeInfoKind.Method and child:get_accessMode() ~= "pri" and not child:get_staticFlag() then
            local childName = advertiseInfo:get_prefix() .. child:getTxt(  )
            
            if not methodNameSet[childName] then
              self.scope:addMethod( child, child:get_accessMode(), child:get_staticFlag(), false )
            end
          end
        end
      else 
        self:error( string.format( "advertise member type is illegal -- %s", advertiseInfo:get_member():get_name()) )
      end
    end
    
  end
  self:popClass(  )
  return node
end

function TransUnit:addMethod( className, methodNode, name )
  local classTypeInfo = self.scope:getTypeInfo( className, self.scope, false )
  
  local classNodeInfo = _lune.unwrap( self.typeInfo2ClassNode[classTypeInfo])
  
  classNodeInfo:get_outerMethodSet()[name] = true
  table.insert( classNodeInfo:get_fieldList(), methodNode )
end

function TransUnit:analyzeDeclFunc( moduleFlag, abstructFlag, overrideFlag, accessMode, staticFlag, classNameToken, firstToken, name )
  local token = self:getToken(  )
  
  do
    local _exp = name
    if _exp ~= nil then
    
        name = self:checkSymbol( _exp )
      else
    
        if token.txt ~= "(" then
          name = self:checkSymbol( token )
          token = self:getToken(  )
        end
      end
  end
  
  local needPopFlag = false
  
  if token.txt == "." then
    needPopFlag = true
    classNameToken = name
    local classTypeInfo = _lune.unwrap( self.scope:getTypeInfoChild( (_lune.unwrap( name) ).txt ))
    
    self:pushClass( classTypeInfo:get_kind() == Ast.TypeInfoKind.Class, classTypeInfo:get_abstructFlag(), nil, nil, false, (_lune.unwrap( name) ).txt, "pub" )
    name = self:getSymbolToken(  )
    token = self:getToken(  )
  end
  local kind = Ast.nodeKindDeclConstr
  
  local typeKind = Ast.TypeInfoKind.Func
  
  if classNameToken then
    if moduleFlag or not staticFlag then
      typeKind = Ast.TypeInfoKind.Method
    end
    if (_lune.unwrap( name) ).txt == "__init" then
      kind = Ast.nodeKindDeclConstr
      for symbolName, symbolInfo in pairs( self.scope:get_symbol2TypeInfoMap() ) do
        if not symbolInfo:get_staticFlag() then
          symbolInfo:set_hasValueFlag( false )
        end
      end
    else 
      kind = Ast.nodeKindDeclMethod
    end
  else 
    kind = Ast.nodeKindDeclFunc
    if not staticFlag then
      staticFlag = true
    end
  end
  if moduleFlag then
    staticFlag = true
  end
  local funcName = ""
  
  do
    local _exp = name
    if _exp ~= nil then
    
        funcName = _exp.txt
        if kind == Ast.nodeKindDeclFunc then
          do
            local _switchExp = accessMode
            if _switchExp == "pub" or _switchExp == "global" then
              if self.scope ~= self.moduleScope then
                self:addErrMess( firstToken.pos, "'global' or 'pub' function must exist top scope." )
              end
            end
          end
          
        end
      end
  end
  
  self:checkToken( token, "(" )
  local scope = self:pushScope( false )
  
  local argList = {}
  
  token = self:analyzeDeclArgList( accessMode, argList )
  local argTypeList = {}
  
  for __index, argNode in pairs( argList ) do
    table.insert( argTypeList, argNode:get_expType() )
  end
  self:checkToken( token, ")" )
  token = self:getToken(  )
  local mutable = false
  
  if token.txt == "mut" then
    token = self:getToken(  )
    mutable = true
  end
  if kind == Ast.nodeKindDeclMethod or kind == Ast.nodeKindDeclConstr then
    if kind == Ast.nodeKindDeclConstr then
      mutable = true
    end
    local classTypeInfo = _lune.unwrap( scope:get_parent():get_ownerTypeInfo())
    
    if classTypeInfo:get_mutable() and not mutable then
      classTypeInfo = self:createModifier( classTypeInfo, false )
    end
    self.scope:add( Ast.SymbolKind.Var, false, true, "self", classTypeInfo, "pri", false, mutable, true )
  end
  local retTypeInfoList = {}
  
  if token.txt == ":" then
    repeat 
      local refType = self:analyzeRefType( accessMode, true )
      
      table.insert( retTypeInfoList, refType:get_expType() )
      token = self:getToken(  )
    until token.txt ~= ","
  end
  local typeInfo = Ast.NormalTypeInfo.createFunc( abstructFlag, false, scope, typeKind, self:getCurrentNamespaceTypeInfo(  ), false, false, staticFlag, accessMode, funcName, argTypeList, retTypeInfoList, mutable )
  
  do
    local _exp = name
    if _exp ~= nil then
    
        local parentScope = scope:get_parent(  )
        
        if accessMode == "global" then
          parentScope = Ast.rootScope
        end
        if kind == Ast.nodeKindDeclFunc then
          parentScope:addFunc( typeInfo, accessMode, staticFlag, mutable )
        else 
          parentScope:addMethod( typeInfo, accessMode, staticFlag, mutable )
        end
      end
  end
  
  if overrideFlag then
    if not name then
      self:addErrMess( firstToken.pos, "can't override anonymous func" )
    end
    -- none
    
    local overrideType = self.scope:get_parent():getTypeInfoField( funcName, false, scope )
    
        if  nil == overrideType then
          local _overrideType = overrideType
          
          self:addErrMess( firstToken.pos, "not found override -- " .. funcName )
        else
          
            if overrideType:get_accessMode(  ) ~= accessMode then
              self:addErrMess( firstToken.pos, string.format( "mismatch override accessMode -- %s,%s,%s", funcName, overrideType:get_accessMode(  ), accessMode) )
            end
            if overrideType:get_staticFlag(  ) ~= staticFlag then
              self:addErrMess( firstToken.pos, "mismatch override staticFlag -- " .. funcName )
            end
            if overrideType:get_kind(  ) ~= Ast.TypeInfoKind.Method then
              self:addErrMess( firstToken.pos, string.format( "mismatch override kind -- %s, %d", funcName, overrideType:get_kind(  )) )
            end
            if overrideType:get_mutable() ~= typeInfo:get_mutable() then
              self:addErrMess( firstToken.pos, string.format( "mismatch mutable -- %s", funcName) )
            end
            if not overrideType:canEvalWith( typeInfo, "=" ) then
              self:addErrMess( firstToken.pos, string.format( "mismatch method type -- %s", funcName) )
            end
          end
      
  else 
    do
      local _exp = name
      if _exp ~= nil then
      
          if _exp.txt ~= "__init" and self.scope:get_parent():getTypeInfoField( _exp.txt, false, scope ) then
            self:error( "mismatch override --" .. funcName )
          end
        end
    end
    
  end
  local node = self:createNoneNode( firstToken.pos )
  
  if token.txt == ";" then
    node = self:createNoneNode( firstToken.pos )
  else 
    self:pushback(  )
    local body = self:analyzeBlock( "func", scope )
    
    local info = Ast.DeclFuncInfo.new(classNameToken, name, argList, staticFlag, accessMode, body, retTypeInfoList)
    
    do
      local _switchExp = (kind )
      if _switchExp == Ast.nodeKindDeclConstr then
        node = Ast.DeclConstrNode.new(firstToken.pos, {typeInfo}, info)
      elseif _switchExp == Ast.nodeKindDeclMethod then
        node = Ast.DeclMethodNode.new(firstToken.pos, {typeInfo}, info)
      elseif _switchExp == Ast.nodeKindDeclFunc then
        node = Ast.DeclFuncNode.new(firstToken.pos, {typeInfo}, info)
      else 
        self:error( string.format( "illegal kind -- %d", kind) )
      end
    end
    
  end
  self:popScope(  )
  if needPopFlag then
    self:addMethod( (_lune.unwrap( classNameToken) ).txt, node, funcName )
    self:popClass(  )
  end
  return node
end

local LetVarInfo = {}
function LetVarInfo.new( mutable, varName, varType )
  local obj = {}
  setmetatable( obj, { __index = LetVarInfo } )
  if obj.__init then
    obj:__init( mutable, varName, varType )
  end        
  return obj 
end         
function LetVarInfo:__init( mutable, varName, varType ) 

self.mutable = mutable
  self.varName = varName
  self.varType = varType
  end
do
  end

function TransUnit:analyzeLetAndInitExp( firstPos, initMutable, accessMode, unwrapFlag )
  local typeInfoList = {}
  
  local letVarList = {}
  
  local nextToken = Parser.getEofToken(  )
  
  repeat 
    local mutable = initMutable
    
    nextToken = self:getToken(  )
    if nextToken.txt == "mut" then
      mutable = true
      nextToken = self:getToken(  )
    end
    local varName = self:checkSymbol( nextToken )
    
    nextToken = self:getToken(  )
    local typeInfo = Ast.builtinTypeNone
    
    if nextToken.txt == ":" then
      local refType = self:analyzeRefType( accessMode, false )
      
      table.insert( letVarList, LetVarInfo.new(mutable, varName, refType) )
      typeInfo = refType:get_expType()
      nextToken = self:getToken(  )
    else 
      table.insert( letVarList, LetVarInfo.new(mutable, varName, nil) )
    end
    if not typeInfo:equals( Ast.builtinTypeNone ) and typeInfo:get_mutable() and not mutable then
      typeInfo = self:createModifier( typeInfo, false )
    end
    table.insert( typeInfoList, typeInfo )
  until nextToken.txt ~= ","
  local expList = nil
  
  if nextToken.txt == "=" then
    expList = self:analyzeExpList( false )
    if not expList then
      self:error( "expList is nil" )
    end
  end
  local orgExpTypeList = {}
  
  do
    local _exp = expList
    if _exp ~= nil then
    
        for index, exp in pairs( _exp:get_expList() ) do
          if not exp:canBeRight(  ) then
            self:addErrMess( exp:get_pos(), string.format( "this node can not be r-value. -- %s", Ast.getNodeKindName( exp:get_kind() )) )
          end
        end
        local expTypeList = {}
        
        for index, expType in pairs( _exp:get_expTypeList() ) do
          local processedFlag = false
          
          if index == #_exp:get_expTypeList() and _exp:get_expTypeList()[index]:equals( Ast.builtinTypeDDD ) then
            for subIndex = index, #letVarList do
              local argType = typeInfoList[subIndex]
              
              local checkType = Ast.builtinTypeStem_
              
              if unwrapFlag then
                checkType = Ast.builtinTypeStem
              end
              if not argType:equals( Ast.builtinTypeNone ) and not argType:canEvalWith( checkType, "=" ) then
                self:addErrMess( firstPos, string.format( "unmatch value type (index = %d) %s(%d) <- %s(%d)", subIndex, argType:getTxt(  ), argType:get_typeId(), Ast.builtinTypeStem_:getTxt(  ), Ast.builtinTypeStem_:get_typeId()) )
              end
              table.insert( expTypeList, checkType )
              table.insert( orgExpTypeList, Ast.builtinTypeStem_ )
            end
          else 
            local expTypeInfo = expType
            
            if expType:equals( Ast.builtinTypeDDD ) then
              expTypeInfo = Ast.builtinTypeStem_
            end
            table.insert( orgExpTypeList, expTypeInfo )
            if unwrapFlag and expTypeInfo:get_nilable() then
              expTypeInfo = _lune.unwrap( expTypeInfo:get_orgTypeInfo())
            end
            if index <= #typeInfoList then
              local argType = typeInfoList[index]
              
              if not argType:equals( Ast.builtinTypeNone ) and not argType:canEvalWith( expTypeInfo, "=" ) and not (unwrapFlag and expTypeInfo:equals( Ast.builtinTypeNil ) ) then
                self:addErrMess( firstPos, string.format( "unmatch value type (index:%d) %s <- %s", index, argType:getTxt(  ), expTypeInfo:getTxt(  )) )
              end
            end
            table.insert( expTypeList, expTypeInfo )
          end
        end
        for index, varType in pairs( typeInfoList ) do
          if index > #expTypeList then
            if not varType:get_nilable() then
              self:addErrMess( firstPos, string.format( "unmatch value type (index:%d) %s <- nil", index, varType:getTxt(  )) )
            end
          end
        end
        for index, typeInfo in pairs( expTypeList ) do
          if not typeInfoList[index] or typeInfoList[index]:equals( Ast.builtinTypeNone ) then
            if typeInfo:get_mutable() and index <= #letVarList and not letVarList[index].mutable then
              typeInfoList[index] = self:createModifier( typeInfo, false )
            else 
              typeInfoList[index] = typeInfo
            end
          end
        end
      end
  end
  
  return typeInfoList, letVarList, orgExpTypeList, expList
end

function TransUnit:analyzeDeclVar( mode, accessMode, firstToken )
  local unwrapFlag = false
  
  local token, continueFlag = self:getContinueToken(  )
  
  if continueFlag and token.txt == "!" then
    unwrapFlag = true
  else 
    self:pushback(  )
    if mode ~= "let" then
      Util.log( "need '!'" )
    end
  end
  if accessMode == "pub" then
    if self.scope ~= self.moduleScope then
      self:addErrMess( firstToken.pos, "'pub' variable must exist top scope." )
    end
  end
  local typeInfoList, letVarList, orgExpTypeList, expList = self:analyzeLetAndInitExp( firstToken.pos, mode == "sync", accessMode, unwrapFlag )
  
  if mode ~= "sync" and self.macroScope then
    for index, letVarInfo in pairs( letVarList ) do
      local typeInfo = typeInfoList[index]
      
      self.symbol2ValueMapForMacro[letVarInfo.varName.txt] = Ast.MacroValInfo.new(nil, typeInfo)
    end
  end
  local syncScope = self.scope
  
  if mode == "sync" then
    syncScope = self:pushScope( false )
  end
  local symbolInfoList = {}
  
  local varList = {}
  
  local syncSymbolList = {}
  
  for index, letVarInfo in pairs( letVarList ) do
    local varName = letVarInfo.varName
    
    local typeInfo = typeInfoList[index]
    
    local varInfo = Ast.VarInfo.new(varName, letVarInfo.varType, typeInfo)
    
    table.insert( varList, varInfo )
    if not letVarInfo.varType and typeInfo:equals( Ast.builtinTypeNil ) then
      self:addErrMess( varName.pos, string.format( 'need type -- %s', varName.txt) )
    end
    if mode == "sync" then
      if self.scope:getTypeInfo( varName.txt, self.scope, true ) then
        table.insert( syncSymbolList, varInfo )
      end
    end
    if mode == "let" or mode == "sync" then
      if mode == "let" then
        if self.scope:getTypeInfo( varName.txt, self.scope, true ) then
          self:addErrMess( varName.pos, string.format( "shadowing variable -- %s", varName.txt) )
        end
      end
      self.scope:addVar( accessMode, varName.txt, typeInfo, letVarInfo.mutable, not unwrapFlag )
    end
    table.insert( symbolInfoList, _lune.unwrap( self.scope:getSymbolInfo( varName.txt, self.scope, true )) )
  end
  local unwrapBlock = nil
  
  local thenBlock = nil
  
  if unwrapFlag then
    local scope = self:pushScope( false )
    
    for index, letVarInfo in pairs( letVarList ) do
      self.scope:addLocalVar( false, true, "_" .. letVarInfo.varName.txt, orgExpTypeList[index], false )
    end
    unwrapBlock = self:analyzeBlock( "let!", scope )
    self:popScope(  )
    if mode == "let" or mode == "sync" then
      for index, letVarInfo in pairs( letVarList ) do
        local symbolInfo = _lune.unwrap( self.scope:getSymbolInfoChild( letVarInfo.varName.txt ))
        
        symbolInfo:set_hasValueFlag( true )
      end
    end
    token = self:getToken( true )
    if token.txt == "then" then
      thenBlock = self:analyzeBlock( "let!", scope )
    else 
      self:pushback(  )
    end
  end
  local syncBlock = nil
  
  if mode == "sync" then
    local nextToken = self:getToken(  )
    
    if nextToken.txt == "do" then
      syncBlock = self:analyzeBlock( "let!", syncScope )
    else 
      self:pushback(  )
    end
    self:popScope(  )
  end
  self:checkNextToken( ";" )
  local node = Ast.DeclVarNode.new(firstToken.pos, {Ast.builtinTypeNone}, mode, accessMode, false, varList, expList, symbolInfoList, typeInfoList, unwrapFlag, unwrapBlock, thenBlock, syncSymbolList, syncBlock)
  
  return node
end

function TransUnit:analyzeIfUnwrap( firstToken )
  local nextToken = self:getToken(  )
  
  local typeInfoList = {}
  
  local varNameList = {}
  
  local expNodeList = {}
  
  if nextToken.txt == "let" then
    local workTypeInfoList, letVarList, orgExpTypeList, expList = self:analyzeLetAndInitExp( firstToken.pos, false, "local", true )
    
    typeInfoList = workTypeInfoList
    for __index, exp in pairs( (_lune.unwrap( expList) ):get_expList() ) do
      table.insert( expNodeList, exp )
    end
    for __index, varInfo in pairs( letVarList ) do
      table.insert( varNameList, varInfo.varName.txt )
    end
  else 
    self:pushback(  )
    local exp = self:analyzeExp( false )
    
    table.insert( expNodeList, exp )
    if exp:get_expType():get_nilable() then
      table.insert( typeInfoList, exp:get_expType():get_orgTypeInfo() )
    else 
      table.insert( typeInfoList, exp:get_expType() )
    end
    table.insert( varNameList, "_exp" )
  end
  local scope = self:pushScope( false )
  
  for index, expType in pairs( typeInfoList ) do
    local varName = varNameList[index]
    
    if self.scope:getSymbolTypeInfo( varName, self.scope, self.moduleScope ) then
      self:addErrMess( firstToken.pos, string.format( "shadowing variable -- %s", varName) )
    end
    scope:addLocalVar( false, true, varName, expType, false )
  end
  local block = self:analyzeBlock( "if!", scope )
  
  self:popScope(  )
  local elseBlock = nil
  
  nextToken = self:getToken( true )
  if nextToken.txt == "else" then
    elseBlock = self:analyzeBlock( "if!" )
  else 
    self:pushback(  )
  end
  return Ast.IfUnwrapNode.new(firstToken.pos, {Ast.builtinTypeNone}, varNameList, expNodeList, block, elseBlock)
end

function TransUnit:analyzeExpList( skipOp2Flag, expNode )
  local expList = {}
  
  local pos = nil
  
  local expTypeList = {}
  
  do
    local _exp = expNode
    if _exp ~= nil then
    
        pos = _exp:get_pos()
        table.insert( expList, _exp )
        table.insert( expTypeList, _exp:get_expType() )
      end
  end
  
  repeat 
    local exp = self:analyzeExp( skipOp2Flag, 0 )
    
    if not pos then
      pos = exp:get_pos()
    end
    table.insert( expList, exp )
    table.insert( expTypeList, exp:get_expType() )
    local token = self:getToken(  )
    
  until token.txt ~= ","
  for index, expType in pairs( expList[#expList]:get_expTypeList() ) do
    if index ~= 1 then
      table.insert( expTypeList, expType )
    end
  end
  self:pushback(  )
  return Ast.ExpListNode.new(_lune.unwrapDefault( pos, Parser.Position.new(0, 0)), expTypeList, expList)
end

function TransUnit:analyzeListConst( token )
  local nextToken = self:getToken(  )
  
  local expList = nil
  
  local itemTypeInfo = Ast.builtinTypeNone
  
  if nextToken.txt ~= "]" then
    self:pushback(  )
    expList = self:analyzeExpList( false )
    self:checkNextToken( "]" )
    local nodeList = (_lune.unwrap( expList) ):get_expList()
    
    for __index, exp in pairs( nodeList ) do
      local expType = exp:get_expType()
      
      if itemTypeInfo:equals( Ast.builtinTypeNone ) then
        itemTypeInfo = expType
      elseif not itemTypeInfo:canEvalWith( expType, "=" ) then
        if expType:equals( Ast.builtinTypeNil ) then
          itemTypeInfo = _lune.unwrap( itemTypeInfo:get_nilableTypeInfo())
        elseif expType:get_nilable() then
          itemTypeInfo = Ast.builtinTypeStem_
        else 
          itemTypeInfo = Ast.builtinTypeStem
        end
      end
    end
  end
  local kind = Ast.nodeKindLiteralArray
  
  local typeInfoList = {Ast.builtinTypeNone}
  
  if token.txt == '[' then
    kind = Ast.nodeKindLiteralList
    typeInfoList = {Ast.NormalTypeInfo.createList( "local", self:getCurrentClass(  ), {itemTypeInfo} )}
    return Ast.LiteralListNode.new(token.pos, typeInfoList, expList)
  else 
    typeInfoList = {Ast.NormalTypeInfo.createArray( "local", self:getCurrentClass(  ), {itemTypeInfo} )}
    return Ast.LiteralArrayNode.new(token.pos, typeInfoList, expList)
  end
end

function TransUnit:analyzeMapConst( token )
  local nextToken = self:getToken(  )
  
  local map = {}
  
  local pairList = {}
  
  local keyTypeInfo = Ast.builtinTypeNone
  
  local valTypeInfo = Ast.builtinTypeNone
  
  local function getMapKeyValType( pos, keyFlag, typeInfo, expType )
    if expType:get_nilable() then
      if keyFlag then
        self:addErrMess( pos, string.format( "map key can't set a nilable -- %s", expType:getTxt(  )) )
      end
      if expType:equals( Ast.builtinTypeNil ) then
        return typeInfo
      end
      expType = _lune.unwrap( expType:get_orgTypeInfo())
    end
    if not typeInfo:canEvalWith( expType, "=" ) then
      if not typeInfo:equals( Ast.builtinTypeNone ) then
        typeInfo = Ast.builtinTypeStem
      else 
        typeInfo = expType
      end
    end
    return typeInfo
  end
  
  while true do
    if nextToken.txt == "}" then
      break
    end
    self:pushback(  )
    local key = self:analyzeExp( false )
    
    keyTypeInfo = getMapKeyValType( key:get_pos(), true, keyTypeInfo, key:get_expType() )
    self:checkNextToken( ":" )
    local val = self:analyzeExp( false )
    
    valTypeInfo = getMapKeyValType( val:get_pos(), false, valTypeInfo, val:get_expType() )
    table.insert( pairList, Ast.PairItem.new(key, val) )
    map[key] = val
    nextToken = self:getToken(  )
    if nextToken.txt ~= "," then
      break
    end
    nextToken = self:getToken(  )
  end
  local typeInfo = Ast.NormalTypeInfo.createMap( "local", self:getCurrentClass(  ), keyTypeInfo, valTypeInfo )
  
  self:checkToken( nextToken, "}" )
  return Ast.LiteralMapNode.new(token.pos, {typeInfo}, map, pairList)
end

function TransUnit:analyzeExpRefItem( token, exp, nilAccess )
  local indexExp = self:analyzeExp( false )
  
  self:checkNextToken( "]" )
  local expType = exp:get_expType()
  
  if nilAccess then
    if not expType:get_nilable() then
      nilAccess = false
    else 
      expType = _lune.unwrap( expType:get_orgTypeInfo())
    end
  end
  local typeInfo = Ast.builtinTypeStem_
  
  if expType:get_kind() == Ast.TypeInfoKind.Map then
    typeInfo = expType:get_itemTypeInfoList(  )[2]
    if not typeInfo:equals( Ast.builtinTypeStem_ ) and not typeInfo:get_nilable() then
      typeInfo = typeInfo:get_nilableTypeInfo()
    end
  elseif expType:get_kind() == Ast.TypeInfoKind.Array or expType:get_kind() == Ast.TypeInfoKind.List then
    typeInfo = expType:get_itemTypeInfoList(  )[1]
  elseif expType:equals( Ast.builtinTypeString ) then
    typeInfo = Ast.builtinTypeInt
  elseif expType:equals( Ast.builtinTypeStem ) then
    typeInfo = Ast.builtinTypeStem
  else 
    self:addErrMess( exp:get_pos(), string.format( "could not access with []. -- %s", expType:getTxt(  )) )
  end
  if not typeInfo then
    self:error( "illegal type" )
  end
  if nilAccess then
    self.useNilAccess = true
  end
  if typeInfo:get_mutable() and not expType:get_mutable() then
    typeInfo = self:createModifier( typeInfo, false )
  end
  return Ast.ExpRefItemNode.new(token.pos, {typeInfo}, exp, nilAccess, nil, indexExp)
end

function TransUnit:checkMatchType( message, pos, dstTypeList, expNodeList, allowDstShort )
  local expTypeList = {}
  
  for index, expNode in pairs( expNodeList ) do
    if index == #expNodeList then
      for __index, expType in pairs( expNode:get_expTypeList() ) do
        table.insert( expTypeList, expType )
      end
    else 
      table.insert( expTypeList, expNode:get_expType() )
    end
  end
  local match, mess = Ast.TypeInfo.checkMatchType( dstTypeList, expTypeList, allowDstShort )
  
  if not match then
    self:addErrMess( pos, string.format( "%s: %s", message, mess) )
  end
end

function TransUnit:checkMatchValType( pos, funcTypeInfo, expList, genericTypeList )
  local argTypeList = funcTypeInfo:get_argTypeInfoList()
  
  do
    local _switchExp = funcTypeInfo
    if _switchExp == _moduleObj.typeInfoListInsert then
      argTypeList = genericTypeList
    elseif _switchExp == _moduleObj.typeInfoListRemove then
    end
  end
  
  local expNodeList = {}
  
  do
    local _exp = expList
    if _exp ~= nil then
    
        expNodeList = _exp:get_expList()
      end
  end
  
  self:checkMatchType( funcTypeInfo:getTxt(  ), pos, argTypeList, expNodeList, false )
end

local MacroPaser = {}
setmetatable( MacroPaser, { __index = Parser } )
function MacroPaser.new( tokenList, name )
  local obj = {}
  setmetatable( obj, { __index = MacroPaser } )
  if obj.__init then obj:__init( tokenList, name ); end
return obj
end
function MacroPaser:__init(tokenList, name) 
  self.pos = 1
  self.tokenList = tokenList
  self.name = name
end
function MacroPaser:getToken(  )
  if #self.tokenList < self.pos then
    return nil
  end
  local token = self.tokenList[self.pos]
  
  self.pos = self.pos + 1
  return token
end
function MacroPaser:getStreamName(  )
  return self.name
end
do
  end

function TransUnit:evalMacro( firstToken, macroTypeInfo, expList )
  do
    local _exp = expList
    if _exp ~= nil then
    
        if _exp:get_expList(  ) then
          for __index, exp in pairs( _exp:get_expList(  ) ) do
            local kind = exp:get_kind()
            
            if kind ~= Ast.nodeKindLiteralNil and kind ~= Ast.nodeKindLiteralChar and kind ~= Ast.nodeKindLiteralInt and kind ~= Ast.nodeKindLiteralReal and kind ~= Ast.nodeKindLiteralArray and kind ~= Ast.nodeKindLiteralList and kind ~= Ast.nodeKindLiteralMap and kind ~= Ast.nodeKindLiteralString and kind ~= Ast.nodeKindLiteralBool and kind ~= Ast.nodeKindLiteralSymbol and kind ~= Ast.nodeKindRefField and kind ~= Ast.nodeKindExpMacroStat then
              self:error( "Macro arguments must be literal value." )
            end
          end
        end
      end
  end
  
  local macroInfo = _lune.unwrap( self.typeId2MacroInfo[macroTypeInfo:get_typeId(  )])
  
  local argValMap = {}
  
  local macroArgValMap = {}
  
  local macroArgNodeList = macroInfo.declInfo:get_argList()
  
  do
    local _exp = expList
    if _exp ~= nil then
    
        for index, argNode in pairs( _exp:get_expList(  ) ) do
          local valList, typeInfoList = argNode:getLiteral(  )
          
          local typeInfo = typeInfoList[1]
          
          local val = valList[1]
          
              if  nil == val then
                local _val = val
                
              else
                
                  argValMap[index] = val
                  local declArgNode = macroArgNodeList[index]
                  
                  macroArgValMap[declArgNode:get_name().txt] = val
                end
            
        end
      end
  end
  
  local func = macroInfo.func
  
  local macroVars = func( macroArgValMap )
  
  for __index, name in pairs( (_lune.unwrap( macroVars['_names']) ) ) do
    local valInfo = _lune.unwrap( macroInfo.symbol2MacroValInfoMap[name])
    
    local typeInfo = valInfo and valInfo.typeInfo or Ast.builtinTypeStem_
    
    local val = macroVars[name]
    
    if typeInfo:equals( Ast.builtinTypeSymbol ) then
      val = {val}
    end
    self.symbol2ValueMapForMacro[name] = Ast.MacroValInfo.new(val, typeInfo)
  end
  local argList = macroInfo.declInfo:get_argList()
  
  if argList then
    for index, arg in pairs( argList ) do
      if arg:get_kind(  ) == Ast.nodeKindDeclArg then
        local argInfo = arg
        
        local argType = argInfo:get_argType()
        
        local argName = argInfo:get_name().txt
        
        self.symbol2ValueMapForMacro[argName] = Ast.MacroValInfo.new(argValMap[index], argType:get_expType())
      else 
        self:error( "not support ... in macro" )
      end
    end
  end
  local parser = MacroPaser.new(macroInfo.declInfo:get_tokenList(), string.format( "macro %s", macroTypeInfo:getTxt(  )))
  
  local bakParser = self.parser
  
  self.parser = parser
  self.macroMode = "expand"
  local stmtList = {}
  
  self:analyzeStatementList( stmtList, "}" )
  self.macroMode = "none"
  self.parser = bakParser
  return Ast.ExpMacroExpNode.new(firstToken.pos, {Ast.builtinTypeNone}, stmtList)
end

function TransUnit:analyzeExpCont( firstToken, exp, skipFlag )
  local nextToken = self:getToken(  )
  
  if not skipFlag then
    repeat 
      local matchFlag = false
      
      if nextToken.txt == "[" or nextToken.txt == "$[" then
        matchFlag = true
        exp = self:analyzeExpRefItem( nextToken, exp, nextToken.txt == "$[" )
        nextToken = self:getToken(  )
      end
      if nextToken.txt == "(" or nextToken.txt == "$(" then
        local macroFlag = false
        
        local funcTypeInfo = exp:get_expType()
        
        local nilAccess = nextToken.txt == "$("
        
        if nilAccess then
          if funcTypeInfo:get_nilable() then
            funcTypeInfo = funcTypeInfo:get_orgTypeInfo()
          else 
            nilAccess = false
          end
        end
        if funcTypeInfo:get_kind(  ) == Ast.TypeInfoKind.Macro then
          macroFlag = true
          self.symbol2ValueMapForMacro = {}
          self.macroMode = "analyze"
        end
        matchFlag = true
        local work = self:getToken(  )
        
        local expList = nil
        
        if work.txt ~= ")" then
          self:pushback(  )
          expList = self:analyzeExpList( false )
          self:checkNextToken( ")" )
        end
        local genericTypeList = funcTypeInfo:get_itemTypeInfoList()
        
        if funcTypeInfo:get_kind() == Ast.TypeInfoKind.Method and exp:get_kind() == Ast.nodeKindRefField then
          local refField = exp
          
          local classType = refField:get_prefix():get_expType()
          
          genericTypeList = classType:get_itemTypeInfoList()
        end
        self:checkMatchValType( exp:get_pos(), funcTypeInfo, expList, genericTypeList )
        if funcTypeInfo:equals( _moduleObj.typeInfoListInsert ) then
          do
            local _exp = expList
            if _exp ~= nil then
            
                if _exp:get_expType():get_nilable() then
                  self:addErrMess( _exp:get_pos(), "list can't insert nilable" )
                end
              end
          end
          
        end
        if macroFlag then
          self.macroMode = "none"
          exp = self:evalMacro( firstToken, funcTypeInfo, expList )
        else 
          do
            local _switchExp = (funcTypeInfo:get_kind() )
            if _switchExp == Ast.TypeInfoKind.Method or _switchExp == Ast.TypeInfoKind.Func then
            else 
              self:error( string.format( "can't call the type -- %s, %s", funcTypeInfo:getTxt(  ), Ast.TypeInfoKind:_getTxt( funcTypeInfo:get_kind())
              ) )
            end
          end
          
          local retTypeInfoList = funcTypeInfo:get_retTypeInfoList(  )
          
          if nilAccess then
            local retList = {}
            
            for __index, retType in pairs( funcTypeInfo:get_retTypeInfoList(  ) ) do
              if retType:get_nilable() then
                table.insert( retList, retType )
              else 
                table.insert( retList, retType:get_nilableTypeInfo() )
              end
            end
            retTypeInfoList = retList
            self.useNilAccess = true
          end
          exp = Ast.ExpCallNode.new(firstToken.pos, retTypeInfoList, exp, nilAccess, expList)
        end
        nextToken = self:getToken(  )
      end
    until not matchFlag
  end
  do
    local _switchExp = nextToken.txt
    if _switchExp == "." then
      return self:analyzeExpSymbol( firstToken, self:getToken(  ), "field", exp, skipFlag )
    elseif _switchExp == "$." then
      return self:analyzeExpSymbol( firstToken, self:getToken(  ), "field_nil", exp, skipFlag )
    elseif _switchExp == ".$" then
      return self:analyzeExpSymbol( firstToken, self:getToken(  ), "get", exp, skipFlag )
    elseif _switchExp == "$.$" then
      return self:analyzeExpSymbol( firstToken, self:getToken(  ), "get_nil", exp, skipFlag )
    end
  end
  
  self:pushback(  )
  return exp
end

function TransUnit:analyzeAccessClassField( classTypeInfo, mode, token )
  if classTypeInfo:get_kind(  ) == Ast.TypeInfoKind.List then
    classTypeInfo = Ast.builtinTypeList
  end
  local className = classTypeInfo:getTxt(  )
  
  local classScope = classTypeInfo:get_scope()
  
      if  nil == classScope then
        local _classScope = classScope
        
        self:error( string.format( "not found field: %s, %s, %s", classScope, className, classTypeInfo) )
      end
    
  local symbolInfo = nil
  
  local fieldTypeInfo = nil
  
  local getterFlag = false
  
  if mode == "get" or mode == "get_nil" then
    local fieldSymbolInfo = classScope:getSymbolInfo( string.format( "get_%s", token.txt), self.scope, false )
    
    do
      local _exp = fieldSymbolInfo
      if _exp ~= nil then
      
          if (_exp:get_kind(  ) == Ast.SymbolKind.Mtd ) then
            local retTypeList = _exp:get_typeInfo():get_retTypeInfoList(  )
            
            symbolInfo = _exp
            if #retTypeList > 0 then
              fieldTypeInfo = retTypeList[1]
            end
            getterFlag = true
          end
        end
    end
    
  end
  if not symbolInfo then
    symbolInfo = classScope:getSymbolInfoField( token.txt, true, self.scope )
    do
      local _exp = symbolInfo
      if _exp ~= nil then
      
          fieldTypeInfo = _exp:get_typeInfo()
        end
    end
    
  end
  if not fieldTypeInfo then
    for name, val in pairs( classScope:get_symbol2TypeInfoMap() ) do
      Util.log( string.format( "debug: %s, %s", name, val) )
    end
    self:error( string.format( "not found field typeInfo: %s.%s", className, token.txt) )
  end
  local typeInfo = _lune.unwrapDefault( fieldTypeInfo, Ast.builtinTypeNone)
  
  return typeInfo, symbolInfo, getterFlag
end

function TransUnit:dumpComp( writer, pattern, symbolInfo, getterFlag )
  local symbol = symbolInfo:get_name()
  
  if pattern == "" or symbol:find( pattern ) then
    if getterFlag then
      writer:startParent( "candidate", false )
      local typeInfo = symbolInfo:get_typeInfo()
      
      writer:write( "type", string.format( "%s", Ast.SymbolKind:_getTxt( symbolInfo:get_kind())
      ) )
      do
        local _switchExp = (symbolInfo:get_kind() )
        if _switchExp == Ast.SymbolKind.Mtd then
          writer:write( "displayTxt", string.format( "$%s", typeInfo:get_rawTxt():gsub( "^get_", "" )) )
        elseif _switchExp == Ast.SymbolKind.Mbr then
          writer:write( "displayTxt", string.format( "$%s: %s", symbolInfo:get_name(), typeInfo:getTxt(  )) )
        end
      end
      
    else 
      writer:startParent( "candidate", false )
      local typeInfo = symbolInfo:get_typeInfo()
      
      writer:write( "type", string.format( "%s", Ast.SymbolKind:_getTxt( symbolInfo:get_kind())
      ) )
      do
        local _switchExp = (symbolInfo:get_kind() )
        if _switchExp == Ast.SymbolKind.Fun or _switchExp == Ast.SymbolKind.Mtd then
          writer:write( "displayTxt", string.format( "%s", typeInfo:get_display_stirng()) )
        elseif _switchExp == Ast.SymbolKind.Mbr or _switchExp == Ast.SymbolKind.Var then
          writer:write( "displayTxt", string.format( "%s: %s", symbolInfo:get_name(), typeInfo:get_display_stirng()) )
        elseif _switchExp == Ast.SymbolKind.Typ then
          writer:write( "displayTxt", string.format( "%s", typeInfo:get_display_stirng()) )
        end
      end
      
    end
    writer:endElement(  )
  end
  return true
end

function TransUnit:dumpFieldComp( writer, prefixSymbolInfo, prefixTypeInfo, pattern, getterPattern )
  local typeInfo = prefixTypeInfo
  
  local scope = typeInfo:get_scope()
  
      if  nil == scope then
        local _scope = scope
        
        return 
      end
    
  local isPrefixType = false
  
  do
    local _exp = prefixSymbolInfo
    if _exp ~= nil then
    
        isPrefixType = _exp:get_kind() == Ast.SymbolKind.Typ
      end
  end
  
  scope:filterTypeInfoField( true, self.scope, function ( symbolInfo )
    if (isPrefixType ) then
      if not symbolInfo:get_staticFlag() and not symbolInfo:get_typeInfo():get_staticFlag() and symbolInfo:get_kind() ~= Ast.SymbolKind.Typ then
        return true
      end
    elseif symbolInfo:get_staticFlag() then
      return true
    end
    local symbol = symbolInfo:get_name()
    
    if symbol ~= "__init" and symbol ~= "self" then
      do
        local _exp = getterPattern
        if _exp ~= nil then
        
            if symbolInfo:get_kind() == Ast.SymbolKind.Mtd then
              local typeInfo = symbolInfo:get_typeInfo()
              
              local retList = typeInfo:get_retTypeInfoList()
              
              if #retList == 1 then
                return self:dumpComp( writer, _exp, symbolInfo, true )
              end
            end
            return true
          end
      end
      
      return self:dumpComp( writer, pattern, symbolInfo, false )
    end
    return true
  end
   )
end

function TransUnit:dumpSymbolComp( writer, scope, pattern )
  scope:filterSymbolTypeInfo( scope, self.moduleScope, function ( symbolInfo )
    return self:dumpComp( writer, pattern, symbolInfo, false )
  end
   )
end

function TransUnit:checkComp( token, callback )
  if self.analyzeMode == "comp" and self.analyzePos.lineNo == token.pos.lineNo and self.analyzePos.column >= token.pos.column and self.analyzePos.column <= token.pos.column + #token.txt then
    local currentModule = self.parser:getStreamName(  ):gsub( "%.lns", "" )
    
    currentModule = currentModule:gsub( ".*/", "" )
    local target = self.analyzeModule:gsub( "[^%.]+%.", "" )
    
    if currentModule == target then
      local jsonWriter = Writer.JSON.new(io.stdout)
      
      jsonWriter:startParent( "lunescript", false )
      local prefix = token.txt:gsub( "lune$", "" )
      
      jsonWriter:write( "prefix", prefix )
      jsonWriter:startParent( "candidateList", true )
      callback( jsonWriter, prefix )
      jsonWriter:endElement(  )
      jsonWriter:endElement(  )
      jsonWriter:fin(  )
      os.exit( 0 )
    end
  end
end

function TransUnit:checkFieldComp( getterFlag, token, prefixExp )
  if self.analyzeMode ~= "comp" then
    return 
  end
  local prefixSymbolInfoList = prefixExp:getSymbolInfo(  )
  
  local prefixSymbolInfo = nil
  
  if #prefixSymbolInfoList == 1 then
    prefixSymbolInfo = prefixSymbolInfoList[1]
  end
  self:checkComp( token, function ( jsonWriter, prefix )
    local getterPattern = nil
    
    if getterFlag then
      getterPattern = "^get_" .. prefix
    end
    self:dumpFieldComp( jsonWriter, prefixSymbolInfo, prefixExp:get_expType(), prefix == "" and "" or "^" .. prefix, getterPattern )
  end
   )
end

function TransUnit:checkSymbolComp( token )
  self:checkComp( token, function ( jsonWriter, prefix )
    self:dumpSymbolComp( jsonWriter, self.scope, prefix == "" and "" or "^" .. prefix )
  end
   )
end

function TransUnit:analyzeExpField( firstToken, token, mode, prefixExp )
  local accessNil = false
  
  if mode == "field_nil" or mode == "get_nil" then
    accessNil = true
  end
  if self.macroMode == "analyze" then
    if accessNil then
      self.useNilAccess = true
    end
    return Ast.RefFieldNode.new(firstToken.pos, {Ast.builtinTypeSymbol}, token, nil, accessNil, _lune.unwrap( prefixExp))
  end
  local typeInfo = Ast.builtinTypeStem_
  
  local prefixExpType = prefixExp:get_expType()
  
  self:checkFieldComp( mode == "get" or mode == "get_nil", token, prefixExp )
  if accessNil then
    if prefixExpType:get_nilable() then
      prefixExpType = _lune.unwrap( prefixExpType:get_orgTypeInfo())
    else 
      accessNil = false
    end
  end
  local getterTypeInfo = nil
  
  local symbolInfo = nil
  
  if prefixExpType:get_kind(  ) == Ast.TypeInfoKind.Class or prefixExpType:get_kind(  ) == Ast.TypeInfoKind.Module or prefixExpType:get_kind(  ) == Ast.TypeInfoKind.IF or prefixExpType:get_kind(  ) == Ast.TypeInfoKind.List then
    local getterFlag = false
    
    typeInfo, symbolInfo, getterFlag = self:analyzeAccessClassField( prefixExpType, mode, token )
    if getterFlag then
      do
        local _exp = symbolInfo
        if _exp ~= nil then
        
            getterTypeInfo = _exp:get_typeInfo()
          end
      end
      
    end
  elseif prefixExpType:get_kind(  ) == Ast.TypeInfoKind.Enum then
    local scope = _lune.unwrap( prefixExpType:get_scope())
    
    local fieldName = token.txt
    
    if mode == "get" then
      fieldName = "get_" .. fieldName
      getterTypeInfo = Ast.rootTypeInfo
    end
    do
      local _exp = scope:getTypeInfoChild( fieldName )
      if _exp ~= nil then
      
          typeInfo = _exp
        else
      
          self:addErrMess( token.pos, string.format( "not found enum field -- %s", token.txt) )
          typeInfo = Ast.builtinTypeInt
        end
    end
    
  elseif prefixExpType:get_kind(  ) == Ast.TypeInfoKind.Map then
    local work = prefixExpType:get_itemTypeInfoList()[1]
    
    if not work:equals( Ast.builtinTypeString ) then
      self:addErrMess( token.pos, string.format( "map key type is not str. (%s)", work:getTxt(  )) )
    end
    typeInfo = prefixExpType:get_itemTypeInfoList()[2]
    if not typeInfo:get_nilable() then
      typeInfo = typeInfo:get_nilableTypeInfo()
    end
    return Ast.ExpRefItemNode.new(token.pos, {typeInfo}, prefixExp, accessNil, token.txt, nil)
  elseif prefixExpType:equals( Ast.builtinTypeStem ) then
    return Ast.ExpRefItemNode.new(token.pos, {Ast.builtinTypeStem_}, prefixExp, accessNil, token.txt, nil)
  else 
    self:error( string.format( "illegal type -- %s, %d", prefixExpType:getTxt(  ), prefixExpType:get_kind(  )) )
  end
  if not symbolInfo then
    local prefixScope = prefixExpType:get_scope()
    
    do
      local _exp = prefixScope
      if _exp ~= nil then
      
          symbolInfo = _exp:getSymbolInfoField( token.txt, true, self.scope )
        end
    end
    
  end
  local prefixSymbolInfoList = prefixExp:getSymbolInfo(  )
  
  local prefixSymbolInfo = nil
  
  if #prefixSymbolInfoList == 1 then
    prefixSymbolInfo = prefixSymbolInfoList[1]
  end
  do
    local _exp = symbolInfo
    if _exp ~= nil then
    
        local prefixSymbolInfo = prefixSymbolInfo
        
            if  nil == prefixSymbolInfo then
              local _prefixSymbolInfo = prefixSymbolInfo
              
            else
              
                if prefixSymbolInfo:get_kind() == Ast.SymbolKind.Typ then
                  if not _exp:get_staticFlag() and _exp:get_kind() ~= Ast.SymbolKind.Typ then
                    self:addErrMess( token.pos, string.format( "Type can't access this symbol. -- %s", _exp:get_name()) )
                  end
                elseif _exp:get_staticFlag() then
                  self:addErrMess( token.pos, string.format( "can't access this symbol. -- %s", token.txt) )
                end
              end
          
        if not prefixExpType:get_mutable() and not _exp:get_staticFlag() and _exp:get_kind() == Ast.SymbolKind.Mtd and _exp:get_mutable() then
          self:addErrMess( token.pos, string.format( "can't access mutable method. -- %s", token.txt) )
        end
      end
  end
  
  if accessNil then
    if not typeInfo:get_nilable() then
      typeInfo = typeInfo:get_nilableTypeInfo()
    end
    self.useNilAccess = true
  end
  local accessSymbolInfo = nil
  
  do
    local _exp = symbolInfo
    if _exp ~= nil then
    
        accessSymbolInfo = Ast.AccessSymbolInfo.new(_exp, prefixExpType, not accessNil)
      end
  end
  
  -- none
  
  if not prefixExpType:get_mutable() and typeInfo:get_mutable() then
    typeInfo = self:createModifier( typeInfo, false )
  end
  do
    local _exp = getterTypeInfo
    if _exp ~= nil then
    
        return Ast.GetFieldNode.new(firstToken.pos, {typeInfo}, token, accessSymbolInfo, accessNil, prefixExp, _exp)
      else
    
        return Ast.RefFieldNode.new(firstToken.pos, {typeInfo}, token, accessSymbolInfo, accessNil, prefixExp)
      end
  end
  
end

function TransUnit:analyzeExpSymbol( firstToken, token, mode, prefixExp, skipFlag )
  local exp = nil
  
  if mode == "field" or mode == "get" or mode == "field_nil" or mode == "get_nil" then
    exp = self:analyzeExpField( firstToken, token, mode, _lune.unwrap( prefixExp) )
  elseif mode == "symbol" then
    if self.macroMode == "analyze" then
      exp = Ast.LiteralSymbolNode.new(firstToken.pos, {Ast.builtinTypeSymbol}, token)
    else 
      self:checkSymbolComp( token )
      local symbolInfo = self.scope:getSymbolTypeInfo( token.txt, self.scope, self.moduleScope )
      
          if  nil == symbolInfo then
            local _symbolInfo = symbolInfo
            
            self:error( "not found type -- " .. token.txt )
          end
        
      local typeInfo = symbolInfo:get_typeInfo()
      
      if typeInfo:equals( Ast.builtinTypeSymbol ) then
        skipFlag = true
      end
      exp = Ast.ExpRefNode.new(firstToken.pos, {typeInfo}, token, Ast.AccessSymbolInfo.new(symbolInfo, nil, true))
    end
  elseif mode == "fn" then
    exp = self:analyzeDeclFunc( false, false, false, "local", false, nil, token, nil )
  else 
    self:error( string.format( "illegal mode -- %s", mode) )
  end
  return self:analyzeExpCont( firstToken, _lune.unwrap( exp), skipFlag )
end

function TransUnit:analyzeExpOpSet( exp, opeToken, exp2NodeList )
  if not exp:canBeLeft(  ) then
    self:addErrMess( exp:get_pos(), string.format( "this node can not be l-value. -- %s", Ast.getNodeKindName( exp:get_kind() )) )
  end
  self:checkMatchType( "= operator", opeToken.pos, exp:get_expTypeList(), exp2NodeList, true )
  for __index, symbolInfo in pairs( exp:getSymbolInfo(  ) ) do
    if not symbolInfo:get_mutable() and symbolInfo:get_hasValueFlag() then
      if self.validMutControl then
        self:addErrMess( opeToken.pos, string.format( "this is not mutable variable. -- %s", symbolInfo:get_name()) )
      end
    end
    symbolInfo:set_hasValueFlag( true )
  end
end

function TransUnit:analyzeExpOp2( firstToken, exp, prevOpLevel )
  while true do
    local nextToken = self:getToken(  )
    
    local opTxt = nextToken.txt
    
    if opTxt == "@@" then
      local castType = self:analyzeRefType( "local", false )
      
      if exp:get_expType():get_nilable() and not castType:get_expType():get_nilable() then
        self:addErrMess( firstToken.pos, string.format( "can't cast from nilable to not nilable  -- %s->%s", exp:get_expType():getTxt(  ), castType:get_expType():getTxt(  )) )
      end
      exp = Ast.ExpCastNode.new(firstToken.pos, castType:get_expTypeList(), exp)
    elseif nextToken.kind == Parser.TokenKind.Ope then
      if Parser.isOp2( opTxt ) then
        local opLevel = op2levelMap[opTxt]
        
            if  nil == opLevel then
              local _opLevel = opLevel
              
              self:error( string.format( "unknown op -- %s %s", opTxt, prevOpLevel) )
            end
          
        do
          local _exp = prevOpLevel
          if _exp ~= nil then
          
              if opLevel <= _exp then
                self:pushback(  )
                return exp
              end
            end
        end
        
        local exp2 = self:analyzeExp( false, opLevel )
        
        local exp2NodeList = {exp2}
        
        if opTxt == "=" then
          local workToken = self:getToken(  )
          
          if workToken.txt == "," then
            local expListNode = self:analyzeExpList( false, exp2 )
            
            exp2 = expListNode
            exp2NodeList = expListNode:get_expList()
          else 
            self:pushback(  )
          end
        end
        local info = {["op"] = nextToken, ["exp1"] = exp, ["exp2"] = exp2}
        
        if not exp:get_expType() or not exp2:get_expType() then
          self:error( string.format( "illegal exp or exp2 %s, %s, %s , %s,%d:%d", exp:get_expType(), exp2:get_expType(), nextToken.txt, self.parser:getStreamName(  ), nextToken.pos.lineNo, nextToken.pos.column) )
        end
        local retType = Ast.builtinTypeNone
        
        if not exp2:canBeRight(  ) then
          self:addErrMess( exp2:get_pos(), string.format( "this node can not be r-value. -- %s", Ast.getNodeKindName( exp2:get_kind() )) )
        end
        local exp1Type = exp:get_expType()
        
        local exp2Type = exp2:get_expType()
        
        if not exp1Type then
          self:error( string.format( "expType is nil %s:%d:%d", self.parser:getStreamName(  ), firstToken.pos.lineNo, firstToken.pos.column) )
        end
        do
          local _switchExp = opTxt
          if _switchExp == "or" then
            if exp1Type:equals( exp2Type ) then
              retType = exp1Type
            elseif exp1Type:get_kind() == exp2Type:get_kind() then
              retType = exp1Type
            elseif exp2Type:equals( Ast.builtinTypeNil ) then
              retType = exp1Type
            elseif exp1Type:equals( Ast.builtinTypeNil ) then
              retType = exp2Type
            else 
              retType = Ast.builtinTypeStem_
            end
          elseif _switchExp == "and" then
            retType = exp2Type
          elseif _switchExp == "<" or _switchExp == ">" or _switchExp == "<=" or _switchExp == ">=" then
            if (not Ast.builtinTypeInt:canEvalWith( exp1Type, opTxt ) and not Ast.builtinTypeReal:canEvalWith( exp1Type, opTxt ) ) or (not Ast.builtinTypeInt:canEvalWith( exp2Type, opTxt ) and not Ast.builtinTypeReal:canEvalWith( exp2Type, opTxt ) ) then
              self:addErrMess( nextToken.pos, string.format( "no numeric type %s or %s", exp1Type:getTxt(  ), exp2Type:getTxt(  )) )
            end
            retType = Ast.builtinTypeBool
          elseif _switchExp == "~=" or _switchExp == "==" then
            if (not exp1Type:canEvalWith( exp2Type, opTxt ) and not exp2Type:canEvalWith( exp1Type, opTxt ) ) then
              self:addErrMess( nextToken.pos, string.format( "not compatible type %s or %s", exp1Type:getTxt(  ), exp2Type:getTxt(  )) )
            end
            retType = Ast.builtinTypeBool
          elseif _switchExp == "^" or _switchExp == "|" or _switchExp == "~" or _switchExp == "&" or _switchExp == "<<" or _switchExp == ">>" then
            if not Ast.builtinTypeInt:canEvalWith( exp1Type, opTxt ) or not Ast.builtinTypeInt:canEvalWith( exp2Type, opTxt ) then
              self:addErrMess( nextToken.pos, string.format( "no int type %s or %s", exp1Type:getTxt(  ), exp2Type:getTxt(  )) )
            end
            retType = Ast.builtinTypeInt
          elseif _switchExp == ".." then
            if not exp1Type:equals( Ast.builtinTypeString ) or not exp1Type:equals( Ast.builtinTypeString ) then
              self:addErrMess( nextToken.pos, string.format( "no string type %s or %s", exp1Type:getTxt(  ), exp2Type:getTxt(  )) )
            end
            retType = Ast.builtinTypeString
          elseif _switchExp == "+" or _switchExp == "-" or _switchExp == "*" or _switchExp == "/" or _switchExp == "//" or _switchExp == "%" then
            if (not Ast.builtinTypeInt:canEvalWith( exp1Type, opTxt ) and not Ast.builtinTypeReal:canEvalWith( exp1Type, opTxt ) ) or (not Ast.builtinTypeInt:canEvalWith( exp2Type, opTxt ) and not Ast.builtinTypeReal:canEvalWith( exp2Type, opTxt ) ) then
              self:addErrMess( nextToken.pos, string.format( "no numeric type %s or %s", exp1Type:getTxt(  ), exp2Type:getTxt(  )) )
            end
            if Ast.builtinTypeReal:canEvalWith( exp1Type, opTxt ) or Ast.builtinTypeReal:canEvalWith( exp2Type, opTxt ) then
              retType = Ast.builtinTypeReal
            else 
              retType = Ast.builtinTypeInt
            end
          elseif _switchExp == "=" then
            self:analyzeExpOpSet( exp, nextToken, exp2NodeList )
          else 
            self:error( "unknown op " .. opTxt )
          end
        end
        
        exp = Ast.ExpOp2Node.new(firstToken.pos, {retType}, nextToken, exp, exp2)
      else 
        self:error( "illegal op" )
      end
    else 
      self:pushback(  )
      return exp
    end
  end
  return self:analyzeExpOp2( firstToken, exp, prevOpLevel )
end

function TransUnit:analyzeExpMacroStat( firstToken )
  local expStrList = {}
  
  self:checkNextToken( "{" )
  local braceCount = 0
  
  local prevToken = firstToken
  
  while true do
    local token = self:getToken(  )
    
    if token.txt == ",," or token.txt == ",,," or token.txt == ",,,," then
      local exp = self:analyzeExp( true, _lune.unwrap( op1levelMap[token.txt]) )
      
      local nextToken = self:getToken(  )
      
      if nextToken.txt ~= "~~" then
        self:pushback(  )
      end
      local format = token.txt == ",,," and "'%s '" or '"\'%s\'"'
      
      if token.txt == ",," and exp:get_kind() == Ast.nodeKindExpRef then
        local refToken = (exp ):get_token(  )
        
        local macroInfo = self.symbol2ValueMapForMacro[refToken.txt]
        
        if macroInfo then
          if (_lune.unwrap( macroInfo) ).typeInfo:equals( Ast.builtinTypeSymbol ) then
            format = "'%s '"
          end
        else 
          if exp:get_expType():equals( Ast.builtinTypeInt ) or exp:get_expType():equals( Ast.builtinTypeReal ) then
            format = "'%s' "
          end
        end
      end
      local newToken = Parser.Token.new(Parser.TokenKind.Str, format, token.pos)
      
      local literalStr = Ast.LiteralStringNode.new(token.pos, {Ast.builtinTypeString}, newToken, {exp})
      
      table.insert( expStrList, literalStr )
    else 
      if token.txt == "{" then
        braceCount = braceCount + 1
      elseif token.txt == "}" then
        if braceCount == 0 then
          break
        end
        braceCount = braceCount - 1
      end
      local format = "' %s '"
      
      if prevToken == firstToken or (prevToken.pos.lineNo == token.pos.lineNo and prevToken.pos.column + #prevToken.txt == token.pos.column ) then
        format = "'%s'"
      end
      local newToken = Parser.Token.new(token.kind, string.format( format, token.txt ), token.pos)
      
      local literalStr = Ast.LiteralStringNode.new(token.pos, {Ast.builtinTypeString}, newToken, {})
      
      table.insert( expStrList, literalStr )
    end
    prevToken = token
  end
  return Ast.ExpMacroStatNode.new(firstToken.pos, {Ast.builtinTypeStat}, expStrList)
end

function TransUnit:analyzeSuper( firstToken )
  self:checkNextToken( "(" )
  local expList = self:analyzeExpList( false )
  
  self:checkNextToken( ")" )
  self:checkNextToken( ";" )
  local classType = self:getCurrentClass(  )
  
  local superType = classType:get_baseTypeInfo(  )
  
  return Ast.ExpCallSuperNode.new(firstToken.pos, {Ast.builtinTypeNone}, superType, expList)
end

function TransUnit:analyzeUnwrap( firstToken )
  local nextToken, continueFlag = self:getContinueToken(  )
  
  if not continueFlag or nextToken.txt ~= "!" then
    self:pushback(  )
    self:pushbackToken( firstToken )
    local exp = self:analyzeExp( false )
    
    self:checkNextToken( ";" )
    return Ast.StmtExpNode.new(nextToken.pos, {Ast.builtinTypeNone}, exp)
  end
  self:pushback(  )
  return self:analyzeDeclVar( "unwrap", "local", firstToken )
end

function TransUnit:analyzeExpUnwrap( firstToken )
  local expNode = self:analyzeExp( true )
  
  local nextToken = self:getToken(  )
  
  local insNode = nil
  
  if nextToken.txt == "default" then
    insNode = self:analyzeExp( false )
  else 
    self:pushback(  )
  end
  local unwrapType = Ast.builtinTypeStem_
  
  local expType = expNode:get_expType()
  
  if not expType:get_nilable() then
    unwrapType = expType
  else 
    unwrapType = _lune.unwrap( expType:get_orgTypeInfo())
    do
      local _exp = insNode
      if _exp ~= nil then
      
          local insType = _exp:get_expType()
          
          unwrapType = insType
          if not unwrapType:canEvalWith( insType, "=" ) then
            self:addErrMess( _exp:get_pos(), string.format( "unmatch type: %s <- %s", unwrapType:getTxt(  ), insType:getTxt(  )) )
          end
        end
    end
    
  end
  self.useUnwrapExp = true
  return Ast.ExpUnwrapNode.new(firstToken.pos, {unwrapType}, expNode, insNode)
end

function TransUnit:analyzeExp( skipOp2Flag, prevOpLevel )
  local firstToken = self:getToken(  )
  
  local token = firstToken
  
  local exp = Ast.NoneNode.new(firstToken.pos, {Ast.builtinTypeNone})
  
  if token.kind == Parser.TokenKind.Dlmt then
    if token.txt == "..." then
      return Ast.ExpDDDNode.new(firstToken.pos, {Ast.builtinTypeNone}, token)
    end
    if token.txt == '[' or token.txt == '[@' then
      exp = self:analyzeListConst( token )
    end
    if token.txt == '{' then
      exp = self:analyzeMapConst( token )
    end
    if token.txt == "(" then
      exp = self:analyzeExp( false )
      self:checkNextToken( ")" )
      exp = Ast.ExpParenNode.new(firstToken.pos, exp:get_expTypeList(), exp)
      exp = self:analyzeExpCont( firstToken, exp, false )
    end
  end
  if token.txt == "new" then
    exp = self:analyzeRefType( "local", false )
    self:checkNextToken( "(" )
    local nextToken = self:getToken(  )
    
    local argList = nil
    
    if nextToken.txt ~= ")" then
      self:pushback(  )
      argList = self:analyzeExpList( false )
      self:checkNextToken( ")" )
    end
    local classTypeInfo = exp:get_expType()
    
    local classScope = classTypeInfo:get_scope(  )
    
    local initTypeInfo = (_lune.unwrap( classScope) ):getTypeInfoChild( "__init" )
    
        if  nil == initTypeInfo then
          local _initTypeInfo = initTypeInfo
          
          self:error( "not found __init" )
        end
      
    if initTypeInfo:get_accessMode() == "pub" or (initTypeInfo:get_accessMode() == "pro" and self.scope:getClassTypeInfo(  ):isInheritFrom( classTypeInfo ) ) or (self.scope:getClassTypeInfo(  ) == classTypeInfo ) then
    else 
      self:addErrMess( token.pos, string.format( "can't access to __init of %s", classTypeInfo:getTxt(  )) )
    end
    self:checkMatchValType( exp:get_pos(), initTypeInfo, argList, exp:get_expType():get_itemTypeInfoList() )
    exp = Ast.ExpNewNode.new(firstToken.pos, exp:get_expTypeList(), exp, argList)
    exp = self:analyzeExpCont( firstToken, exp, false )
  end
  if token.kind == Parser.TokenKind.Ope and Parser.isOp1( token.txt ) then
    if token.txt == "`" then
      exp = self:analyzeExpMacroStat( token )
    else 
      exp = self:analyzeExp( true, _lune.unwrap( op1levelMap[token.txt]) )
      local typeInfo = Ast.builtinTypeNone
      
      local macroExpFlag = false
      
      do
        local _switchExp = (token.txt )
        if _switchExp == "-" then
          if not exp:get_expType():equals( Ast.builtinTypeInt ) and not exp:get_expType():equals( Ast.builtinTypeReal ) then
            self:addErrMess( token.pos, string.format( 'unmatch type for "-" -- %s', exp:get_expType():getTxt(  )) )
          end
          typeInfo = exp:get_expType()
        elseif _switchExp == "#" then
          if exp:get_expType():get_kind() ~= Ast.TypeInfoKind.List and exp:get_expType():get_kind() ~= Ast.TypeInfoKind.Array and exp:get_expType():get_kind() ~= Ast.TypeInfoKind.Map and not Ast.builtinTypeString:canEvalWith( exp:get_expType(), "=" ) then
            self:addErrMess( token.pos, string.format( 'unmatch type for "#" -- %s', exp:get_expType():getTxt(  )) )
          end
          typeInfo = Ast.builtinTypeInt
        elseif _switchExp == "not" then
          typeInfo = Ast.builtinTypeBool
        elseif _switchExp == ",," then
          macroExpFlag = true
        elseif _switchExp == ",,," then
          macroExpFlag = true
          if not exp:get_expType():equals( Ast.builtinTypeString ) then
            self:error( "unmatch ,,, type, need string type" )
          end
          typeInfo = Ast.builtinTypeSymbol
        elseif _switchExp == ",,,," then
          macroExpFlag = true
          if not exp:get_expType():equals( Ast.builtinTypeSymbol ) then
            self:error( "unmatch ,,, type, need symbol type" )
          end
          typeInfo = Ast.builtinTypeString
        elseif _switchExp == "`" then
          typeInfo = Ast.builtinTypeNone
        elseif _switchExp == "not" then
          typeInfo = Ast.builtinTypeBool
        else 
          self:error( "unknown op1" )
        end
      end
      
      if macroExpFlag then
        local nextToken = self:getToken(  )
        
        if nextToken.txt ~= "~~" then
          self:pushback(  )
        end
      end
      exp = Ast.ExpOp1Node.new(firstToken.pos, {typeInfo}, token, self.macroMode, exp)
      return self:analyzeExpOp2( firstToken, exp, prevOpLevel )
    end
  end
  if token.kind == Parser.TokenKind.Int then
    exp = Ast.LiteralIntNode.new(firstToken.pos, {Ast.builtinTypeInt}, token, math.floor(tonumber( token.txt )))
  elseif token.kind == Parser.TokenKind.Real then
    exp = Ast.LiteralRealNode.new(firstToken.pos, {Ast.builtinTypeReal}, token, tonumber( token.txt ))
  elseif token.kind == Parser.TokenKind.Char then
    local num = 0
    
    if #(token.txt ) == 1 then
      num = token.txt:byte( 1 )
    else 
      num = _lune.unwrap( quotedChar2Code[token.txt:sub( 2, 2 )])
    end
    exp = Ast.LiteralCharNode.new(firstToken.pos, {Ast.builtinTypeChar}, token, num)
  elseif token.kind == Parser.TokenKind.Str then
    local nextToken = self:getToken(  )
    
    local formatArgList = {}
    
    if nextToken.txt == "(" then
      repeat 
        local arg = self:analyzeExp( false )
        
        table.insert( formatArgList, arg )
        nextToken = self:getToken(  )
      until nextToken.txt ~= ","
      self:checkToken( nextToken, ")" )
      nextToken = self:getToken(  )
    end
    exp = Ast.LiteralStringNode.new(firstToken.pos, {Ast.builtinTypeString}, token, formatArgList)
    token = nextToken
    if token.txt == "[" or token.txt == "$[" then
      exp = self:analyzeExpRefItem( token, exp, token.txt == "$[" )
    else 
      self:pushback(  )
    end
  elseif token.kind == Parser.TokenKind.Kywd and token.txt == "fn" then
    exp = self:analyzeExpSymbol( firstToken, token, "fn", nil, false )
  elseif token.kind == Parser.TokenKind.Kywd and token.txt == "unwrap" then
    exp = self:analyzeExpUnwrap( token )
  elseif token.kind == Parser.TokenKind.Symb then
    exp = self:analyzeExpSymbol( firstToken, token, "symbol", nil, false )
  elseif token.kind == Parser.TokenKind.Type then
    local symbolTypeInfo = Ast.sym2builtInTypeMap[token.txt]
    
        if  nil == symbolTypeInfo then
          local _symbolTypeInfo = symbolTypeInfo
          
          self:error( string.format( "unknown type -- %s", token.txt) )
        end
      
    exp = Ast.ExpRefNode.new(firstToken.pos, {Ast.builtinTypeNone}, token, Ast.AccessSymbolInfo.new(symbolTypeInfo, nil, false))
  elseif token.kind == Parser.TokenKind.Kywd and (token.txt == "true" or token.txt == "false" ) then
    exp = Ast.LiteralBoolNode.new(firstToken.pos, {Ast.builtinTypeBool}, token)
  elseif token.kind == Parser.TokenKind.Kywd and (token.txt == "nil" or token.txt == "null" ) then
    exp = Ast.LiteralNilNode.new(firstToken.pos, {Ast.builtinTypeNil})
  end
  if not exp then
    self:error( "illegal exp" )
  end
  if skipOp2Flag then
    return exp
  end
  return self:analyzeExpOp2( firstToken, exp, prevOpLevel )
end

function TransUnit:analyzeReturn( token )
  local nextToken = self:getToken(  )
  
  local expList = nil
  
  if nextToken.txt ~= ";" then
    self:pushback(  )
    expList = self:analyzeExpList( false )
    self:checkNextToken( ";" )
  end
  local funcTypeInfo = self:getCurrentNamespaceTypeInfo(  )
  
  if not funcTypeInfo then
    self:addErrMess( token.pos, "'return' could not use here" )
  else 
    local retTypeList = funcTypeInfo:get_retTypeInfoList()
    
    do
      local _exp = expList
      if _exp ~= nil then
      
          local expNodeList = _exp:get_expList()
          
          if #retTypeList == 0 and #expNodeList > 0 then
            self:addErrMess( token.pos, "this function can't return value." )
          end
          for index, retType in pairs( retTypeList ) do
            local expNode = expNodeList[index]
            
            local expType = expNode:get_expType()
            
            if not retType:canEvalWith( expType, "=" ) then
              self:addErrMess( token.pos, string.format( "return type of arg(%d) is not compatible -- %s(%d) and %s(%d)", index, retType:getTxt(  ), retType:get_typeId(  ), expType:getTxt(  ), expType:get_typeId(  )) )
            end
            if index == #retTypeList then
              if #retTypeList < #expNodeList and not retType:equals( Ast.builtinTypeDDD ) then
                self:addErrMess( token.pos, "over return value" )
              end
            elseif index == #expNodeList then
              if expType:equals( Ast.builtinTypeDDD ) then
                for retIndex = index, #retTypeList do
                  local workRetType = retTypeList[retIndex]
                  
                  if not workRetType:canEvalWith( Ast.builtinTypeStem_, "=" ) then
                    self:addErrMess( token.pos, string.format( "return type of arg(%d) is not compatible -- %s(%d) and %s(%d)", retIndex, workRetType:getTxt(  ), workRetType:get_typeId(  ), expType:getTxt(  ), expType:get_typeId(  )) )
                  end
                end
              else 
                self:addErrMess( token.pos, string.format( "short return value -- %d < %d", #expNodeList, #retTypeList) )
              end
              break
            end
          end
        else
      
          if funcTypeInfo:getTxt(  ) == "__init" then
            self:addErrMess( token.pos, "__init method can't return" )
          end
          if #retTypeList ~= 0 then
            self:addErrMess( token.pos, "no return value" )
          end
        end
    end
    
  end
  return Ast.ReturnNode.new(token.pos, {Ast.builtinTypeNone}, expList)
end

function TransUnit:analyzeStatement( termTxt )
  local token = self:getTokenNoErr(  )
  
  if token == Parser.getEofToken(  ) then
    return nil
  end
  -- none
  
  local statement = self:analyzeDecl( "local", false, token, token )
  
  if not statement then
    if token.txt == termTxt then
      self:pushback(  )
      return nil
    elseif token.txt == "pub" or token.txt == "pro" or token.txt == "pri" or token.txt == "global" or token.txt == "static" then
      local accessMode = (token.txt ~= "static" ) and token.txt or "pri"
      
      local staticFlag = (token.txt == "static" )
      
      local nextToken = token
      
      if token.txt ~= "static" then
        nextToken = self:getToken(  )
      end
      statement = self:analyzeDecl( accessMode, staticFlag, token, nextToken )
    elseif token.txt == "{" then
      self:pushback(  )
      statement = self:analyzeBlock( "{" )
    elseif token.txt == "super" then
      statement = self:analyzeSuper( token )
    elseif token.txt == "if" then
      statement = self:analyzeIf( token )
    elseif token.txt == "switch" then
      statement = self:analyzeSwitch( token )
    elseif token.txt == "while" then
      statement = self:analyzeWhile( token )
    elseif token.txt == "repeat" then
      statement = self:analyzeRepeat( token )
    elseif token.txt == "for" then
      statement = self:analyzeFor( token )
    elseif token.txt == "apply" then
      statement = self:analyzeApply( token )
    elseif token.txt == "foreach" then
      statement = self:analyzeForeach( token, false )
    elseif token.txt == "forsort" then
      statement = self:analyzeForeach( token, true )
    elseif token.txt == "return" then
      statement = self:analyzeReturn( token )
    elseif token.txt == "break" then
      self:checkNextToken( ";" )
      statement = Ast.BreakNode.new(token.pos, {Ast.builtinTypeNone})
    elseif token.txt == "unwrap" then
      statement = self:analyzeUnwrap( token )
    elseif token.txt == "sync" then
      statement = self:analyzeDeclVar( "sync", "local", token )
    elseif token.txt == "import" then
      statement = self:analyzeImport( token )
    elseif token.txt == "subfile" then
      statement = self:analyzeSubfile( token )
    elseif token.txt == "_lune_control" then
      self:analyzeLuneControl( token )
      statement = self:createNoneNode( token.pos )
    elseif token.txt == "provide" then
      statement = self:analyzeProvide( token )
    elseif token.txt == ";" then
      statement = self:createNoneNode( token.pos )
    elseif token.txt == ",," or token.txt == ",,," or token.txt == ",,,," then
      self:error( string.format( "illegal macro op -- %s", token.txt) )
    else 
      self:pushback(  )
      local exp = self:analyzeExp( false )
      
      local nextToken = self:getToken(  )
      
      if nextToken.txt == "," then
        exp = self:analyzeExpList( true, exp )
        exp = self:analyzeExpOp2( token, exp, nil )
        nextToken = self:getToken(  )
      end
      self:checkToken( nextToken, ";" )
      statement = Ast.StmtExpNode.new(exp:get_pos(), {Ast.builtinTypeNone}, exp)
    end
  end
  return statement
end

return _moduleObj
