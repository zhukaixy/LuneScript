--lune/base/Ast.lns
local _moduleObj = {}
if not _ENV._lune then
   _lune = {}
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

local Parser = require( 'lune.base.Parser' )

local Util = require( 'lune.base.Util' )

local IdProvider = {}
_moduleObj.IdProvider = IdProvider
function IdProvider:increment(  )
  self.id = self.id + 1
end
function IdProvider:getNewId(  )
  local newId = self.id
  
  self.id = self.id + 1
  return newId
end
function IdProvider.setmeta( obj )
  setmetatable( obj, { __index = IdProvider  } )
end
function IdProvider.new( id )
  local obj = {}
  IdProvider.setmeta( obj )
  if obj.__init then
    obj:__init( id )
  end        
  return obj 
end         
function IdProvider:__init( id ) 

self.id = id
  end
function IdProvider:get_id()       
  return self.id         
end
do
  end

local idProv = IdProvider.new(1)

local rootTypeId = idProv:getNewId(  )

_moduleObj.rootTypeId = rootTypeId

-- none

-- none

local typeInfoKind = {}

_moduleObj.typeInfoKind = typeInfoKind

local sym2builtInTypeMap = {}

_moduleObj.sym2builtInTypeMap = sym2builtInTypeMap

local builtInTypeIdSet = {}

_moduleObj.builtInTypeIdSet = builtInTypeIdSet

local TypeInfoKind = {}
_moduleObj.TypeInfoKind = TypeInfoKind
TypeInfoKind._val2NameMap = {}
function TypeInfoKind:_getTxt( val )
  local name = self._val2NameMap[ val ]
  if name then
    return string.format( "TypeInfoKind.%s", name )
  end
  return string.format( "illegal val -- %s", val )
end 
function TypeInfoKind:_from( val )
  if self._val2NameMap[ val ] then
    return val
  end
  return nil
end 
    
TypeInfoKind.Root = 0
TypeInfoKind._val2NameMap[0] = 'Root'
TypeInfoKind.Macro = 1
TypeInfoKind._val2NameMap[1] = 'Macro'
TypeInfoKind.Prim = 2
TypeInfoKind._val2NameMap[2] = 'Prim'
TypeInfoKind.List = 3
TypeInfoKind._val2NameMap[3] = 'List'
TypeInfoKind.Array = 4
TypeInfoKind._val2NameMap[4] = 'Array'
TypeInfoKind.Map = 5
TypeInfoKind._val2NameMap[5] = 'Map'
TypeInfoKind.Class = 6
TypeInfoKind._val2NameMap[6] = 'Class'
TypeInfoKind.IF = 7
TypeInfoKind._val2NameMap[7] = 'IF'
TypeInfoKind.Func = 8
TypeInfoKind._val2NameMap[8] = 'Func'
TypeInfoKind.Method = 9
TypeInfoKind._val2NameMap[9] = 'Method'
TypeInfoKind.Nilable = 10
TypeInfoKind._val2NameMap[10] = 'Nilable'
TypeInfoKind.Enum = 11
TypeInfoKind._val2NameMap[11] = 'Enum'
TypeInfoKind.Module = 12
TypeInfoKind._val2NameMap[12] = 'Module'
TypeInfoKind.Stem = 13
TypeInfoKind._val2NameMap[13] = 'Stem'

local function isBuiltin( typeId )
  return _moduleObj.builtInTypeIdSet[typeId] ~= nil
end
_moduleObj.isBuiltin = isBuiltin
-- none

local SymbolKind = {}
_moduleObj.SymbolKind = SymbolKind
SymbolKind._val2NameMap = {}
function SymbolKind:_getTxt( val )
  local name = self._val2NameMap[ val ]
  if name then
    return string.format( "SymbolKind.%s", name )
  end
  return string.format( "illegal val -- %s", val )
end 
function SymbolKind:_from( val )
  if self._val2NameMap[ val ] then
    return val
  end
  return nil
end 
    
SymbolKind.Typ = 0
SymbolKind._val2NameMap[0] = 'Typ'
SymbolKind.Mbr = 1
SymbolKind._val2NameMap[1] = 'Mbr'
SymbolKind.Mtd = 2
SymbolKind._val2NameMap[2] = 'Mtd'
SymbolKind.Fun = 3
SymbolKind._val2NameMap[3] = 'Fun'
SymbolKind.Var = 4
SymbolKind._val2NameMap[4] = 'Var'
SymbolKind.Arg = 5
SymbolKind._val2NameMap[5] = 'Arg'

local AccessMode = {}
_moduleObj.AccessMode = AccessMode
AccessMode._val2NameMap = {}
function AccessMode:_getTxt( val )
  local name = self._val2NameMap[ val ]
  if name then
    return string.format( "AccessMode.%s", name )
  end
  return string.format( "illegal val -- %s", val )
end 
function AccessMode:_from( val )
  if self._val2NameMap[ val ] then
    return val
  end
  return nil
end 
    
AccessMode.None = 0
AccessMode._val2NameMap[0] = 'None'
AccessMode.Pub = 1
AccessMode._val2NameMap[1] = 'Pub'
AccessMode.Pro = 2
AccessMode._val2NameMap[2] = 'Pro'
AccessMode.Pri = 3
AccessMode._val2NameMap[3] = 'Pri'
AccessMode.Local = 4
AccessMode._val2NameMap[4] = 'Local'
AccessMode.Global = 5
AccessMode._val2NameMap[5] = 'Global'

local txt2AccessModeMap = {}

txt2AccessModeMap['none'] = AccessMode.None
txt2AccessModeMap['pub'] = AccessMode.Pub
txt2AccessModeMap['pro'] = AccessMode.Pro
txt2AccessModeMap['pri'] = AccessMode.Pri
txt2AccessModeMap['local'] = AccessMode.Local
txt2AccessModeMap['global'] = AccessMode.Global
local function txt2AccessMode( accessMode )
  return txt2AccessModeMap[accessMode]
end
_moduleObj.txt2AccessMode = txt2AccessMode
local SymbolInfo = {}
_moduleObj.SymbolInfo = SymbolInfo
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
-- none
-- none
-- none
function SymbolInfo.setmeta( obj )
  setmetatable( obj, { __index = SymbolInfo  } )
end
function SymbolInfo.new(  )
  local obj = {}
  SymbolInfo.setmeta( obj )
  if obj.__init then
    obj:__init(  )
  end        
  return obj 
end         
function SymbolInfo:__init(  ) 

end
do
  end

local NormalSymbolInfo = {}
setmetatable( NormalSymbolInfo, { __index = SymbolInfo } )
_moduleObj.NormalSymbolInfo = NormalSymbolInfo
function NormalSymbolInfo.new( kind, canBeLeft, canBeRight, scope, accessMode, staticFlag, name, typeInfo, mutable, hasValueFlag )
  local obj = {}
  NormalSymbolInfo.setmeta( obj )
  if obj.__init then obj:__init( kind, canBeLeft, canBeRight, scope, accessMode, staticFlag, name, typeInfo, mutable, hasValueFlag ); end
return obj
end
function NormalSymbolInfo:__init(kind, canBeLeft, canBeRight, scope, accessMode, staticFlag, name, typeInfo, mutable, hasValueFlag) 
  NormalSymbolInfo.symbolIdSeed = NormalSymbolInfo.symbolIdSeed + 1
  self.kind = kind
  self.canBeLeft = canBeLeft
  self.canBeRight = canBeRight
  self.symbolId = NormalSymbolInfo.symbolIdSeed
  self.scope = scope
  self.accessMode = accessMode
  self.staticFlag = staticFlag
  self.name = name
  self.typeInfo = typeInfo
  self.mutable = mutable and true or false
  self.hasValueFlag = hasValueFlag
end
-- none
function NormalSymbolInfo.setmeta( obj )
  setmetatable( obj, { __index = NormalSymbolInfo  } )
end
function NormalSymbolInfo:get_canBeLeft()       
  return self.canBeLeft         
end
function NormalSymbolInfo:get_canBeRight()       
  return self.canBeRight         
end
function NormalSymbolInfo:get_symbolId()       
  return self.symbolId         
end
function NormalSymbolInfo:get_scope()       
  return self.scope         
end
function NormalSymbolInfo:get_accessMode()       
  return self.accessMode         
end
function NormalSymbolInfo:get_staticFlag()       
  return self.staticFlag         
end
function NormalSymbolInfo:get_name()       
  return self.name         
end
function NormalSymbolInfo:get_typeInfo()       
  return self.typeInfo         
end
function NormalSymbolInfo:get_mutable()       
  return self.mutable         
end
function NormalSymbolInfo:get_kind()       
  return self.kind         
end
function NormalSymbolInfo:get_hasValueFlag()       
  return self.hasValueFlag         
end
function NormalSymbolInfo:set_hasValueFlag( hasValueFlag )   
  self.hasValueFlag = hasValueFlag              
end
do
  NormalSymbolInfo.symbolIdSeed = 0
  end

local DataOwnerInfo = {}
_moduleObj.DataOwnerInfo = DataOwnerInfo
function DataOwnerInfo.setmeta( obj )
  setmetatable( obj, { __index = DataOwnerInfo  } )
end
function DataOwnerInfo.new( hasData, symbolInfo )
  local obj = {}
  DataOwnerInfo.setmeta( obj )
  if obj.__init then
    obj:__init( hasData, symbolInfo )
  end        
  return obj 
end         
function DataOwnerInfo:__init( hasData, symbolInfo ) 

self.hasData = hasData
  self.symbolInfo = symbolInfo
  end
do
  end

local Scope = {}
_moduleObj.Scope = Scope
function Scope.new( parent, classFlag, inheritList )
  local obj = {}
  Scope.setmeta( obj )
  if obj.__init then obj:__init( parent, classFlag, inheritList ); end
return obj
end
function Scope:__init(parent, classFlag, inheritList) 
  self.parent = _lune.unwrapDefault( parent, self)
  self.symbol2TypeInfoMap = {}
  self.inheritList = inheritList
  self.classFlag = classFlag
  self.symbolId2DataOwnerInfo = {}
end
function Scope:isRoot(  )
  return self.parent == self
end
function Scope:set_ownerTypeInfo( owner )
  self.ownerTypeInfo = owner
end
function Scope:getTypeInfoChild( name )
  do
    local _exp = self.symbol2TypeInfoMap[name]
    if _exp ~= nil then
    
        return _exp:get_typeInfo()
      end
  end
  
  return nil
end
function Scope:getSymbolInfoChild( name )
  return self.symbol2TypeInfoMap[name]
end
function Scope:setData( symbolInfo )
  self.symbolId2DataOwnerInfo[symbolInfo:get_symbolId()] = DataOwnerInfo.new(true, symbolInfo)
end
-- none
function Scope.setmeta( obj )
  setmetatable( obj, { __index = Scope  } )
end
function Scope:get_ownerTypeInfo()       
  return self.ownerTypeInfo         
end
function Scope:get_parent()       
  return self.parent         
end
function Scope:get_symbol2TypeInfoMap()       
  return self.symbol2TypeInfoMap         
end
function Scope:get_inheritList()       
  return self.inheritList         
end
do
  end

local rootScope = Scope.new(nil, false, {})

_moduleObj.rootScope = rootScope

local dummyList = {}

local rootChildren = {}

local TypeData = {}
function TypeData:addChildren( child )
  table.insert( self.children, child )
end
function TypeData.setmeta( obj )
  setmetatable( obj, { __index = TypeData  } )
end
function TypeData.new( children )
  local obj = {}
  TypeData.setmeta( obj )
  if obj.__init then
    obj:__init( children )
  end        
  return obj 
end         
function TypeData:__init( children ) 

self.children = children
  end
function TypeData:get_children()       
  return self.children         
end
do
  end

local TypeManager = {}
function TypeManager.add( typeInfo )
  TypeManager.info2Data[typeInfo] = TypeData.new({})
end
function TypeManager.getData( typeInfo )
  return TypeManager.info2Data[typeInfo]
end
function TypeManager.setmeta( obj )
  setmetatable( obj, { __index = TypeManager  } )
end
function TypeManager.new(  )
  local obj = {}
  TypeManager.setmeta( obj )
  if obj.__init then
    obj:__init(  )
  end        
  return obj 
end         
function TypeManager:__init(  ) 

end
do
  TypeManager.info2Data = {}
  end

local TypeInfo = {}
_moduleObj.TypeInfo = TypeInfo
function TypeInfo.new( scope )
  local obj = {}
  TypeInfo.setmeta( obj )
  if obj.__init then obj:__init( scope ); end
return obj
end
function TypeInfo:__init(scope) 
  self.scope = scope
  do
    local _exp = scope
    if _exp ~= nil then
    
        _exp:set_ownerTypeInfo( self )
      end
  end
  
  TypeManager.add( self )
end
function TypeInfo:isModule(  )
  return true
end
function TypeInfo:getParentId(  )
  return _moduleObj.rootTypeId
end
function TypeInfo:get_baseId(  )
  return _moduleObj.rootTypeId
end
function TypeInfo:isInheritFrom( other )
  return false
end
function TypeInfo:getTxt(  )
  return ""
end
-- none
function TypeInfo:canEvalWith( other, opTxt )
  return false
end
function TypeInfo:get_abstructFlag(  )
  return false
end
function TypeInfo:serialize( stream, validChildrenSet )
  return 
end
function TypeInfo:get_display_stirng(  )
  return ""
end
function TypeInfo:get_srcTypeInfo(  )
  return self
end
function TypeInfo:equals( typeInfo )
  return self == typeInfo:get_srcTypeInfo()
end
function TypeInfo:get_externalFlag(  )
  return false
end
function TypeInfo:get_interfaceList(  )
  return dummyList
end
function TypeInfo:get_itemTypeInfoList(  )
  return dummyList
end
function TypeInfo:get_argTypeInfoList(  )
  return dummyList
end
function TypeInfo:get_retTypeInfoList(  )
  return dummyList
end
function TypeInfo:get_parentInfo(  )
  return self
end
function TypeInfo:hasRouteNamespaceFrom( other )
  while true do
    if other == self then
      return true
    end
    if other:get_parentInfo() == other then
      break
    end
    other = other:get_parentInfo()
  end
  return false
end
function TypeInfo:getModule(  )
  if self:isModule(  ) then
    return self
  end
  return self:get_parentInfo():getModule(  )
end
function TypeInfo:get_rawTxt(  )
  return ""
end
function TypeInfo:get_typeId(  )
  return _moduleObj.rootTypeId
end
function TypeInfo:get_kind(  )
  return TypeInfoKind.Root
end
function TypeInfo:get_staticFlag(  )
  return false
end
function TypeInfo:get_accessMode(  )
  return AccessMode.Pri
end
function TypeInfo:get_autoFlag(  )
  return false
end
function TypeInfo:get_orgTypeInfo(  )
  return self
end
function TypeInfo:get_baseTypeInfo(  )
  return self
end
function TypeInfo:get_nilable(  )
  return false
end
function TypeInfo:get_nilableTypeInfo(  )
  return self
end
function TypeInfo:get_typeData(  )
  return _lune.unwrap( TypeManager.getData( self ))
end
function TypeInfo:get_children(  )
  return self:get_typeData():get_children()
end
function TypeInfo:addChildren( child )
  (_lune.unwrap( TypeManager.getData( self )) ):addChildren( child )
end
function TypeInfo:get_mutable(  )
  return true
end
function TypeInfo.setmeta( obj )
  setmetatable( obj, { __index = TypeInfo  } )
end
function TypeInfo:get_scope()       
  return self.scope         
end
do
  end

function Scope:filterTypeInfoField( includeSelfFlag, fromScope, callback )
  if self.classFlag then
    if includeSelfFlag then
      for __index, symbolInfo in pairs( self.symbol2TypeInfoMap ) do
        if symbolInfo:canAccess( fromScope ) then
          if not callback( symbolInfo ) then
            return false
          end
        end
      end
    end
    if self.inheritList then
      for __index, scope in pairs( self.inheritList ) do
        if not scope:filterTypeInfoField( true, fromScope, callback ) then
          return false
        end
      end
    end
  end
  return true
end

function Scope:getSymbolInfoField( name, includeSelfFlag, fromScope )
  if self.classFlag then
    if includeSelfFlag then
      do
        local _exp = self.symbol2TypeInfoMap[name]
        if _exp ~= nil then
        
            local symbolInfo = _exp:canAccess( fromScope )
            
                if  nil == symbolInfo then
                  local _symbolInfo = symbolInfo
                  
                  return nil
                end
              
            return symbolInfo
          end
      end
      
    end
    if self.inheritList then
      for __index, scope in pairs( self.inheritList ) do
        local symbolInfo = scope:getSymbolInfoField( name, true, fromScope )
        
        if symbolInfo then
          return symbolInfo
        end
      end
    end
  end
  return nil
end

function Scope:getTypeInfoField( name, includeSelfFlag, fromScope )
  local symbolInfo = self:getSymbolInfoField( name, includeSelfFlag, fromScope )
  
  do
    local _exp = symbolInfo
    if _exp ~= nil then
    
        return _exp:get_typeInfo()
      end
  end
  
  return nil
end

function Scope:getSymbolInfo( name, fromScope, onlySameNsFlag )
  do
    local _exp = self.symbol2TypeInfoMap[name]
    if _exp ~= nil then
    
        local symbolInfo = _exp:canAccess( fromScope )
        
            if  nil == symbolInfo then
              local _symbolInfo = symbolInfo
              
              return nil
            end
          
        return symbolInfo
      end
  end
  
  if not onlySameNsFlag then
    if self.inheritList then
      for __index, scope in pairs( self.inheritList ) do
        local symbolInfo = scope:getSymbolInfoField( name, true, fromScope )
        
        if symbolInfo then
          return symbolInfo
        end
      end
    end
  end
  if not onlySameNsFlag or not self.ownerTypeInfo then
    if self.parent ~= self then
      return self.parent:getSymbolInfo( name, fromScope, onlySameNsFlag )
    end
  end
  if onlySameNsFlag then
    return nil
  end
  do
    local _exp = _moduleObj.sym2builtInTypeMap[name]
    if _exp ~= nil then
    
        return _exp
      end
  end
  
  return nil
end

function Scope:getTypeInfo( name, fromScope, onlySameNsFlag )
  local symbolInfo = self:getSymbolInfo( name, fromScope, onlySameNsFlag )
  
      if  nil == symbolInfo then
        local _symbolInfo = symbolInfo
        
        return nil
      end
    
  return symbolInfo:get_typeInfo()
end

function Scope:getSymbolTypeInfo( name, fromScope, moduleScope )
  local typeInfo = nil
  
  local validThisScope = false
  
  do
    local _exp = self.ownerTypeInfo
    if _exp ~= nil then
    
        if _exp:get_kind() == TypeInfoKind.Func or _exp:get_kind() == TypeInfoKind.Method or self == moduleScope or self == _moduleObj.rootScope then
          validThisScope = true
        elseif (_exp:get_kind() == TypeInfoKind.IF or _exp:get_kind() == TypeInfoKind.Class or _exp:get_kind() == TypeInfoKind.Module ) and name == "self" then
          validThisScope = true
        elseif _exp:get_kind() == TypeInfoKind.Enum then
          validThisScope = true
        end
      else
    
        validThisScope = true
      end
  end
  
  if validThisScope then
    do
      local _exp = self.symbol2TypeInfoMap[name]
      if _exp ~= nil then
      
          return _exp:canAccess( fromScope )
        end
    end
    
  end
  if self.parent ~= self then
    return self.parent:getSymbolTypeInfo( name, fromScope, moduleScope )
  end
  return _moduleObj.sym2builtInTypeMap[name]
end

function Scope:filterSymbolTypeInfo( fromScope, moduleScope, callback )
  if self.classFlag then
    do
      local _exp = self.symbol2TypeInfoMap["self"]
      if _exp ~= nil then
      
          callback( _exp )
        end
    end
    
  end
  if moduleScope == fromScope or not self.classFlag then
    for __index, symbolInfo in pairs( self.symbol2TypeInfoMap ) do
      if not callback( symbolInfo ) then
        return 
      end
    end
  end
  if self.parent ~= self then
    self.parent:filterSymbolTypeInfo( fromScope, moduleScope, callback )
  end
end

function Scope:add( kind, canBeLeft, canBeRight, name, typeInfo, accessMode, staticFlag, mutable, hasValueFlag )
  local symbolInfo = NormalSymbolInfo.new(kind, canBeLeft, canBeRight, self, accessMode, staticFlag, name, typeInfo, mutable, hasValueFlag)
  
  self.symbol2TypeInfoMap[name] = symbolInfo
  return symbolInfo
end

function Scope:addLocalVar( argFlag, canBeLeft, name, typeInfo, mutable )
  self:add( argFlag and SymbolKind.Arg or SymbolKind.Var, canBeLeft, true, name, typeInfo, AccessMode.Local, false, mutable, true )
end

function Scope:addStaticVar( argFlag, canBeLeft, name, typeInfo, mutable )
  self:add( argFlag and SymbolKind.Arg or SymbolKind.Var, canBeLeft, true, name, typeInfo, AccessMode.Local, true, mutable, true )
end

function Scope:addVar( accessMode, name, typeInfo, mutable, hasValueFlag )
  self:add( SymbolKind.Var, true, true, name, typeInfo, accessMode, false, mutable, hasValueFlag )
end

function Scope:addEnumVal( name, typeInfo )
  self:add( SymbolKind.Mbr, false, true, name, typeInfo, AccessMode.Pub, true, true, true )
end

function Scope:addEnum( accessMode, name, typeInfo )
  self:add( SymbolKind.Typ, false, false, name, typeInfo, accessMode, true, true, true )
end

function Scope:addMember( name, typeInfo, accessMode, staticFlag, mutable )
  return self:add( SymbolKind.Mbr, true, true, name, typeInfo, accessMode, staticFlag, mutable, true )
end

function Scope:addMethod( typeInfo, accessMode, staticFlag, mutable )
  self:add( SymbolKind.Mtd, true, true, typeInfo:getTxt(  ), typeInfo, accessMode, staticFlag, mutable, true )
end

function Scope:addFunc( typeInfo, accessMode, staticFlag, mutable )
  self:add( SymbolKind.Fun, true, true, typeInfo:getTxt(  ), typeInfo, accessMode, staticFlag, mutable, true )
end

function Scope:addClass( name, typeInfo )
  self:add( SymbolKind.Typ, false, false, name, typeInfo, typeInfo:get_accessMode(), true, true, true )
end

local function dumpScopeSub( scope, prefix, readyIdSet )
  do
    local _exp = scope
    if _exp ~= nil then
    
        if readyIdSet[_exp] then
          return 
        end
        readyIdSet[_exp] = true
        if #prefix > 20 then
          Util.err( "illegal" )
        end
        do
          local __sorted = {}
          local __map = _exp:get_symbol2TypeInfoMap()
          for __key in pairs( __map ) do
            table.insert( __sorted, __key )
          end
          table.sort( __sorted )
          for __index, symbol in ipairs( __sorted ) do
            symbolInfo = __map[ symbol ]
            do
              Util.log( string.format( "scope: %s, %s, %s", prefix, _exp, symbol) )
              do
                local subScope = symbolInfo:get_typeInfo():get_scope()
                if subScope ~= nil then
                
                    dumpScopeSub( subScope, prefix .. "  ", readyIdSet )
                  end
              end
              
            end
          end
        end
        
      end
  end
  
  -- none
  
end

local function dumpScope( scope, prefix )
  dumpScopeSub( scope, prefix, {} )
end

local headTypeInfo = TypeInfo.new(_moduleObj.rootScope)

_moduleObj.headTypeInfo = headTypeInfo

function Scope:getNSTypeInfo(  )
  local scope = self
  
  while true do
    do
      local owner = scope.ownerTypeInfo
      if owner ~= nil then
      
          if owner:get_kind() == TypeInfoKind.Root then
            return owner
          end
        end
    end
    
    if scope.parent == scope then
      break
    end
    scope = scope.parent
  end
  return _moduleObj.headTypeInfo
end

function Scope:getClassTypeInfo(  )
  local scope = self
  
  while true do
    do
      local owner = scope.ownerTypeInfo
      if owner ~= nil then
      
          do
            local _switchExp = owner:get_kind()
            if _switchExp == TypeInfoKind.Class or _switchExp == TypeInfoKind.IF or _switchExp == TypeInfoKind.Module then
              return owner
            end
          end
          
        end
    end
    
    if scope.parent == scope then
      break
    end
    scope = scope.parent
  end
  return _moduleObj.headTypeInfo
end

function NormalSymbolInfo:canAccess( fromScope )
  local typeInfo = self:get_typeInfo()
  
  if self.scope == fromScope then
    return self
  end
  do
    local _switchExp = self:get_accessMode()
    if _switchExp == AccessMode.Pub or _switchExp == AccessMode.Global then
      return self
    elseif _switchExp == AccessMode.Pro then
      local nsClass = self.scope:getClassTypeInfo(  )
      
      local fromClass = fromScope:getClassTypeInfo(  )
      
      if fromClass:isInheritFrom( nsClass ) then
        return self
      end
      return nil
    elseif _switchExp == AccessMode.Local then
      return self
    elseif _switchExp == AccessMode.Pri then
      local nsClass = self.scope:getClassTypeInfo(  )
      
      local fromClass = fromScope:getClassTypeInfo(  )
      
      if nsClass == fromClass then
        return self
      end
      return nil
    end
  end
  
  Util.err( string.format( "illegl accessmode -- %s, %s", self:get_accessMode(), self:get_name()) )
end

local AccessSymbolInfo = {}
setmetatable( AccessSymbolInfo, { __index = SymbolInfo } )
_moduleObj.AccessSymbolInfo = AccessSymbolInfo
function AccessSymbolInfo:get_mutable(  )
  do
    local _exp = self.prefixTypeInfo
    if _exp ~= nil then
    
        return _exp:get_mutable() and self.symbolInfo:get_mutable()
      end
  end
  
  return self.symbolInfo:get_mutable()
end
function AccessSymbolInfo:get_canBeLeft(  )
  if not self.overrideCanBeLeft then
    return false
  end
  do
    local _exp = self.prefixTypeInfo
    if _exp ~= nil then
    
        if not _exp:get_mutable() then
          return false
        end
      end
  end
  
  return self.symbolInfo:get_canBeLeft()
end
function AccessSymbolInfo.setmeta( obj )
  setmetatable( obj, { __index = AccessSymbolInfo  } )
end
function AccessSymbolInfo.new( symbolInfo, prefixTypeInfo, overrideCanBeLeft )
  local obj = {}
  AccessSymbolInfo.setmeta( obj )
  if obj.__init then
    obj:__init( symbolInfo, prefixTypeInfo, overrideCanBeLeft )
  end        
  return obj 
end         
function AccessSymbolInfo:__init( symbolInfo, prefixTypeInfo, overrideCanBeLeft ) 

self.symbolInfo = symbolInfo
  self.prefixTypeInfo = prefixTypeInfo
  self.overrideCanBeLeft = overrideCanBeLeft
  end
function AccessSymbolInfo:get_symbolInfo()       
  return self.symbolInfo         
end
function AccessSymbolInfo:get_prefixTypeInfo()       
  return self.prefixTypeInfo         
end
function AccessSymbolInfo:get_canBeRight( ... )
  return self.symbolInfo:get_canBeRight( ... )
end       

function AccessSymbolInfo:get_symbolId( ... )
  return self.symbolInfo:get_symbolId( ... )
end       

function AccessSymbolInfo:get_scope( ... )
  return self.symbolInfo:get_scope( ... )
end       

function AccessSymbolInfo:get_accessMode( ... )
  return self.symbolInfo:get_accessMode( ... )
end       

function AccessSymbolInfo:get_staticFlag( ... )
  return self.symbolInfo:get_staticFlag( ... )
end       

function AccessSymbolInfo:get_name( ... )
  return self.symbolInfo:get_name( ... )
end       

function AccessSymbolInfo:get_typeInfo( ... )
  return self.symbolInfo:get_typeInfo( ... )
end       

function AccessSymbolInfo:get_kind( ... )
  return self.symbolInfo:get_kind( ... )
end       

function AccessSymbolInfo:get_hasValueFlag( ... )
  return self.symbolInfo:get_hasValueFlag( ... )
end       

function AccessSymbolInfo:set_hasValueFlag( ... )
  return self.symbolInfo:set_hasValueFlag( ... )
end       

function AccessSymbolInfo:canAccess( ... )
  return self.symbolInfo:canAccess( ... )
end       

do
  end

-- none

-- none

local NilableTypeInfo = {}
setmetatable( NilableTypeInfo, { __index = TypeInfo } )
_moduleObj.NilableTypeInfo = NilableTypeInfo
function NilableTypeInfo:get_kind(  )
  return TypeInfoKind.Nilable
end
function NilableTypeInfo:get_srcTypeInfo(  )
  return self
end
function NilableTypeInfo:get_nilable(  )
  return true
end
function NilableTypeInfo:getTxt(  )
  return self.orgTypeInfo:getTxt(  ) .. "!"
end
function NilableTypeInfo:get_display_stirng(  )
  return self.orgTypeInfo:get_display_stirng() .. "!"
end
function NilableTypeInfo:serialize( stream, validChildrenSet )
  local parentId = self:getParentId(  )
  
  stream:write( string.format( '{ parentId = %d, typeId = %d, nilable = true, orgTypeId = %d }\n', parentId, self.typeId, self.orgTypeInfo:get_typeId()) )
end
function NilableTypeInfo:equals( typeInfo )
  if not typeInfo:get_nilable() then
    return false
  end
  return self.orgTypeInfo:equals( typeInfo )
end
function NilableTypeInfo.setmeta( obj )
  setmetatable( obj, { __index = NilableTypeInfo  } )
end
function NilableTypeInfo.new( orgTypeInfo, typeId )
  local obj = {}
  NilableTypeInfo.setmeta( obj )
  if obj.__init then
    obj:__init( orgTypeInfo, typeId )
  end        
  return obj 
end         
function NilableTypeInfo:__init( orgTypeInfo, typeId ) 

self.orgTypeInfo = orgTypeInfo
  self.typeId = typeId
  end
function NilableTypeInfo:get_orgTypeInfo()       
  return self.orgTypeInfo         
end
function NilableTypeInfo:get_typeId()       
  return self.typeId         
end
function NilableTypeInfo:isModule( ... )
  return self.orgTypeInfo:isModule( ... )
end       

function NilableTypeInfo:getParentId( ... )
  return self.orgTypeInfo:getParentId( ... )
end       

function NilableTypeInfo:get_baseId( ... )
  return self.orgTypeInfo:get_baseId( ... )
end       

function NilableTypeInfo:isInheritFrom( ... )
  return self.orgTypeInfo:isInheritFrom( ... )
end       

function NilableTypeInfo:get_abstructFlag( ... )
  return self.orgTypeInfo:get_abstructFlag( ... )
end       

function NilableTypeInfo:get_externalFlag( ... )
  return self.orgTypeInfo:get_externalFlag( ... )
end       

function NilableTypeInfo:get_interfaceList( ... )
  return self.orgTypeInfo:get_interfaceList( ... )
end       

function NilableTypeInfo:get_itemTypeInfoList( ... )
  return self.orgTypeInfo:get_itemTypeInfoList( ... )
end       

function NilableTypeInfo:get_argTypeInfoList( ... )
  return self.orgTypeInfo:get_argTypeInfoList( ... )
end       

function NilableTypeInfo:get_retTypeInfoList( ... )
  return self.orgTypeInfo:get_retTypeInfoList( ... )
end       

function NilableTypeInfo:get_parentInfo( ... )
  return self.orgTypeInfo:get_parentInfo( ... )
end       

function NilableTypeInfo:hasRouteNamespaceFrom( ... )
  return self.orgTypeInfo:hasRouteNamespaceFrom( ... )
end       

function NilableTypeInfo:getModule( ... )
  return self.orgTypeInfo:getModule( ... )
end       

function NilableTypeInfo:get_rawTxt( ... )
  return self.orgTypeInfo:get_rawTxt( ... )
end       

function NilableTypeInfo:get_staticFlag( ... )
  return self.orgTypeInfo:get_staticFlag( ... )
end       

function NilableTypeInfo:get_accessMode( ... )
  return self.orgTypeInfo:get_accessMode( ... )
end       

function NilableTypeInfo:get_autoFlag( ... )
  return self.orgTypeInfo:get_autoFlag( ... )
end       

function NilableTypeInfo:get_baseTypeInfo( ... )
  return self.orgTypeInfo:get_baseTypeInfo( ... )
end       

function NilableTypeInfo:get_nilableTypeInfo( ... )
  return self.orgTypeInfo:get_nilableTypeInfo( ... )
end       

function NilableTypeInfo:get_typeData( ... )
  return self.orgTypeInfo:get_typeData( ... )
end       

function NilableTypeInfo:get_children( ... )
  return self.orgTypeInfo:get_children( ... )
end       

function NilableTypeInfo:addChildren( ... )
  return self.orgTypeInfo:addChildren( ... )
end       

function NilableTypeInfo:get_mutable( ... )
  return self.orgTypeInfo:get_mutable( ... )
end       

function NilableTypeInfo:get_scope( ... )
  return self.orgTypeInfo:get_scope( ... )
end       

do
  end

local ModifierTypeInfo = {}
setmetatable( ModifierTypeInfo, { __index = TypeInfo } )
_moduleObj.ModifierTypeInfo = ModifierTypeInfo
function ModifierTypeInfo:getTxt(  )
  local txt = self.srcTypeInfo:getTxt(  )
  
  if not self.mutable then
    txt = "&" .. txt
  end
  return txt
end
function ModifierTypeInfo:get_display_stirng(  )
  local txt = self.srcTypeInfo:get_display_stirng(  )
  
  if self.mutable then
    txt = "mut " .. txt
  end
  return txt
end
function ModifierTypeInfo:serialize( stream, validChildrenSet )
  local parentId = self:getParentId(  )
  
  stream:write( string.format( '{ parentId = %d, typeId = %d, srcTypeId = %d, mutable = %s }\n', parentId, self.typeId, self.srcTypeInfo:get_typeId(), self.mutable and true or false) )
end
function ModifierTypeInfo:canEvalWith( other, opTxt )
  return TypeInfo.canEvalWithBase( self.srcTypeInfo, self.mutable, other, opTxt )
end
function ModifierTypeInfo.setmeta( obj )
  setmetatable( obj, { __index = ModifierTypeInfo  } )
end
function ModifierTypeInfo.new( srcTypeInfo, typeId, mutable )
  local obj = {}
  ModifierTypeInfo.setmeta( obj )
  if obj.__init then
    obj:__init( srcTypeInfo, typeId, mutable )
  end        
  return obj 
end         
function ModifierTypeInfo:__init( srcTypeInfo, typeId, mutable ) 

self.srcTypeInfo = srcTypeInfo
  self.typeId = typeId
  self.mutable = mutable
  end
function ModifierTypeInfo:get_srcTypeInfo()       
  return self.srcTypeInfo         
end
function ModifierTypeInfo:get_typeId()       
  return self.typeId         
end
function ModifierTypeInfo:get_mutable()       
  return self.mutable         
end
function ModifierTypeInfo:isModule( ... )
  return self.srcTypeInfo:isModule( ... )
end       

function ModifierTypeInfo:getParentId( ... )
  return self.srcTypeInfo:getParentId( ... )
end       

function ModifierTypeInfo:get_baseId( ... )
  return self.srcTypeInfo:get_baseId( ... )
end       

function ModifierTypeInfo:isInheritFrom( ... )
  return self.srcTypeInfo:isInheritFrom( ... )
end       

function ModifierTypeInfo:get_abstructFlag( ... )
  return self.srcTypeInfo:get_abstructFlag( ... )
end       

function ModifierTypeInfo:equals( ... )
  return self.srcTypeInfo:equals( ... )
end       

function ModifierTypeInfo:get_externalFlag( ... )
  return self.srcTypeInfo:get_externalFlag( ... )
end       

function ModifierTypeInfo:get_interfaceList( ... )
  return self.srcTypeInfo:get_interfaceList( ... )
end       

function ModifierTypeInfo:get_itemTypeInfoList( ... )
  return self.srcTypeInfo:get_itemTypeInfoList( ... )
end       

function ModifierTypeInfo:get_argTypeInfoList( ... )
  return self.srcTypeInfo:get_argTypeInfoList( ... )
end       

function ModifierTypeInfo:get_retTypeInfoList( ... )
  return self.srcTypeInfo:get_retTypeInfoList( ... )
end       

function ModifierTypeInfo:get_parentInfo( ... )
  return self.srcTypeInfo:get_parentInfo( ... )
end       

function ModifierTypeInfo:hasRouteNamespaceFrom( ... )
  return self.srcTypeInfo:hasRouteNamespaceFrom( ... )
end       

function ModifierTypeInfo:getModule( ... )
  return self.srcTypeInfo:getModule( ... )
end       

function ModifierTypeInfo:get_rawTxt( ... )
  return self.srcTypeInfo:get_rawTxt( ... )
end       

function ModifierTypeInfo:get_kind( ... )
  return self.srcTypeInfo:get_kind( ... )
end       

function ModifierTypeInfo:get_staticFlag( ... )
  return self.srcTypeInfo:get_staticFlag( ... )
end       

function ModifierTypeInfo:get_accessMode( ... )
  return self.srcTypeInfo:get_accessMode( ... )
end       

function ModifierTypeInfo:get_autoFlag( ... )
  return self.srcTypeInfo:get_autoFlag( ... )
end       

function ModifierTypeInfo:get_orgTypeInfo( ... )
  return self.srcTypeInfo:get_orgTypeInfo( ... )
end       

function ModifierTypeInfo:get_baseTypeInfo( ... )
  return self.srcTypeInfo:get_baseTypeInfo( ... )
end       

function ModifierTypeInfo:get_nilable( ... )
  return self.srcTypeInfo:get_nilable( ... )
end       

function ModifierTypeInfo:get_nilableTypeInfo( ... )
  return self.srcTypeInfo:get_nilableTypeInfo( ... )
end       

function ModifierTypeInfo:get_typeData( ... )
  return self.srcTypeInfo:get_typeData( ... )
end       

function ModifierTypeInfo:get_children( ... )
  return self.srcTypeInfo:get_children( ... )
end       

function ModifierTypeInfo:addChildren( ... )
  return self.srcTypeInfo:addChildren( ... )
end       

function ModifierTypeInfo:get_scope( ... )
  return self.srcTypeInfo:get_scope( ... )
end       

do
  end

local ModuleTypeInfo = {}
setmetatable( ModuleTypeInfo, { __index = TypeInfo } )
_moduleObj.ModuleTypeInfo = ModuleTypeInfo
function ModuleTypeInfo.new( scope, externalFlag, txt, parentInfo, typeId, mutable )
  local obj = {}
  ModuleTypeInfo.setmeta( obj )
  if obj.__init then obj:__init( scope, externalFlag, txt, parentInfo, typeId, mutable ); end
return obj
end
function ModuleTypeInfo:__init(scope, externalFlag, txt, parentInfo, typeId, mutable) 
  TypeInfo.__init( self, scope)
  
  self.externalFlag = externalFlag
  self.rawTxt = txt
  self.parentInfo = _lune.unwrapDefault( parentInfo, _moduleObj.headTypeInfo)
  self.typeId = typeId
  self.mutable = mutable
  do
    local _exp = parentInfo
    if _exp ~= nil then
    
        _exp:addChildren( self )
      end
  end
  
  idProv:increment(  )
  scope:set_ownerTypeInfo( self )
end
function ModuleTypeInfo:isModule(  )
  return true
end
function ModuleTypeInfo:get_accessMode(  )
  return AccessMode.Pub
end
function ModuleTypeInfo:get_kind(  )
  return TypeInfoKind.Module
end
function ModuleTypeInfo:getParentId(  )
  return self.parentInfo:get_typeId()
end
function ModuleTypeInfo:getTxt(  )
  return self.rawTxt
end
function ModuleTypeInfo:get_display_stirng(  )
  return self:getTxt(  )
end
function ModuleTypeInfo:canEvalWith( other, opTxt )
  return false
end
function ModuleTypeInfo:serialize( stream, validChildrenSet )
  local txt = string.format( "{ parentId = %d, typeId = %d, txt = '%s', kind = %d, ", self:getParentId(  ), self.typeId, self.rawTxt, TypeInfoKind.Module)
  
  stream:write( txt .. '\n' )
  stream:write( "children = {" )
  local set = validChildrenSet
  
      if  nil == set then
        local _set = set
        
        set = {}
      end
    
  do
    local _exp = validChildrenSet
    if _exp ~= nil then
    
        for __index, child in pairs( self:get_children() ) do
          if set[child:get_typeId()] and (child:get_accessMode() == AccessMode.Pub or child:get_accessMode() == AccessMode.Global ) then
            stream:write( string.format( "%d, ", child:get_typeId()) )
          end
        end
      end
  end
  
  stream:write( "} }\n" )
end
function ModuleTypeInfo.setmeta( obj )
  setmetatable( obj, { __index = ModuleTypeInfo  } )
end
function ModuleTypeInfo:get_externalFlag()       
  return self.externalFlag         
end
function ModuleTypeInfo:get_parentInfo()       
  return self.parentInfo         
end
function ModuleTypeInfo:get_typeId()       
  return self.typeId         
end
function ModuleTypeInfo:get_rawTxt()       
  return self.rawTxt         
end
function ModuleTypeInfo:get_mutable()       
  return self.mutable         
end
do
  end

local EnumValInfo = {}
_moduleObj.EnumValInfo = EnumValInfo
function EnumValInfo.setmeta( obj )
  setmetatable( obj, { __index = EnumValInfo  } )
end
function EnumValInfo.new( name, val )
  local obj = {}
  EnumValInfo.setmeta( obj )
  if obj.__init then
    obj:__init( name, val )
  end        
  return obj 
end         
function EnumValInfo:__init( name, val ) 

self.name = name
  self.val = val
  end
function EnumValInfo:get_name()       
  return self.name         
end
function EnumValInfo:get_val()       
  return self.val         
end
do
  end

local EnumTypeInfo = {}
setmetatable( EnumTypeInfo, { __index = TypeInfo } )
_moduleObj.EnumTypeInfo = EnumTypeInfo
function EnumTypeInfo.new( scope, externalFlag, accessMode, txt, parentInfo, typeId, valTypeInfo, name2EnumValInfo )
  local obj = {}
  EnumTypeInfo.setmeta( obj )
  if obj.__init then obj:__init( scope, externalFlag, accessMode, txt, parentInfo, typeId, valTypeInfo, name2EnumValInfo ); end
return obj
end
function EnumTypeInfo:__init(scope, externalFlag, accessMode, txt, parentInfo, typeId, valTypeInfo, name2EnumValInfo) 
  TypeInfo.__init( self, scope)
  
  self.externalFlag = externalFlag
  self.accessMode = accessMode
  self.rawTxt = txt
  self.parentInfo = _lune.unwrapDefault( parentInfo, _moduleObj.headTypeInfo)
  self.typeId = typeId
  self.name2EnumValInfo = name2EnumValInfo
  self.valTypeInfo = valTypeInfo
  do
    local _exp = parentInfo
    if _exp ~= nil then
    
        _exp:addChildren( self )
      end
  end
  
  self.nilableTypeInfo = NilableTypeInfo.new(self, typeId + 1)
  idProv:increment(  )
  scope:set_ownerTypeInfo( self )
end
function EnumTypeInfo:isModule(  )
  return false
end
function EnumTypeInfo:get_kind(  )
  return TypeInfoKind.Enum
end
function EnumTypeInfo:getParentId(  )
  return self.parentInfo:get_typeId()
end
function EnumTypeInfo:getTxt(  )
  return self.rawTxt
end
function EnumTypeInfo:get_display_stirng(  )
  return self:getTxt(  )
end
function EnumTypeInfo:canEvalWith( other, opTxt )
  return self == other:get_srcTypeInfo()
end
function EnumTypeInfo:getEnumValInfo( name )
  return self.name2EnumValInfo[name]
end
function EnumTypeInfo:get_mutable(  )
  return true
end
function EnumTypeInfo.setmeta( obj )
  setmetatable( obj, { __index = EnumTypeInfo  } )
end
function EnumTypeInfo:get_externalFlag()       
  return self.externalFlag         
end
function EnumTypeInfo:get_parentInfo()       
  return self.parentInfo         
end
function EnumTypeInfo:get_typeId()       
  return self.typeId         
end
function EnumTypeInfo:get_rawTxt()       
  return self.rawTxt         
end
function EnumTypeInfo:get_accessMode()       
  return self.accessMode         
end
function EnumTypeInfo:get_nilableTypeInfo()       
  return self.nilableTypeInfo         
end
function EnumTypeInfo:get_valTypeInfo()       
  return self.valTypeInfo         
end
function EnumTypeInfo:get_name2EnumValInfo()       
  return self.name2EnumValInfo         
end
do
  end

local NormalTypeInfo = {}
setmetatable( NormalTypeInfo, { __index = TypeInfo } )
_moduleObj.NormalTypeInfo = NormalTypeInfo
function NormalTypeInfo.new( abstructFlag, scope, baseTypeInfo, interfaceList, orgTypeInfo, autoFlag, externalFlag, staticFlag, accessMode, txt, parentInfo, typeId, kind, itemTypeInfoList, argTypeInfoList, retTypeInfoList, mutable )
  local obj = {}
  NormalTypeInfo.setmeta( obj )
  if obj.__init then obj:__init( abstructFlag, scope, baseTypeInfo, interfaceList, orgTypeInfo, autoFlag, externalFlag, staticFlag, accessMode, txt, parentInfo, typeId, kind, itemTypeInfoList, argTypeInfoList, retTypeInfoList, mutable ); end
return obj
end
function NormalTypeInfo:__init(abstructFlag, scope, baseTypeInfo, interfaceList, orgTypeInfo, autoFlag, externalFlag, staticFlag, accessMode, txt, parentInfo, typeId, kind, itemTypeInfoList, argTypeInfoList, retTypeInfoList, mutable) 
  TypeInfo.__init( self, scope)
  
  if type( kind ) ~= "number" then
    Util.printStackTrace(  )
  end
  self.abstructFlag = abstructFlag
  self.baseTypeInfo = _lune.unwrapDefault( baseTypeInfo, _moduleObj.headTypeInfo)
  self.interfaceList = _lune.unwrapDefault( interfaceList, {})
  self.autoFlag = autoFlag
  self.externalFlag = externalFlag
  self.staticFlag = staticFlag
  self.accessMode = accessMode
  self.rawTxt = txt
  self.kind = kind
  self.itemTypeInfoList = _lune.unwrapDefault( itemTypeInfoList, {})
  self.argTypeInfoList = _lune.unwrapDefault( argTypeInfoList, {})
  self.retTypeInfoList = _lune.unwrapDefault( retTypeInfoList, {})
  self.orgTypeInfo = _lune.unwrapDefault( orgTypeInfo, _moduleObj.headTypeInfo)
  self.parentInfo = _lune.unwrapDefault( parentInfo, _moduleObj.headTypeInfo)
  self.mutable = mutable and true or false
  self.typeId = typeId
  if kind == TypeInfoKind.Root then
    self.nilable = false
  elseif txt == "nil" then
    self.nilable = true
    self.nilableTypeInfo = self
    self.orgTypeInfo = self
  elseif not orgTypeInfo then
    do
      local _exp = parentInfo
      if _exp ~= nil then
      
          _exp:addChildren( self )
        end
    end
    
    self.nilable = false
    local hasNilable = false
    
    do
      local _switchExp = (kind )
      if _switchExp == TypeInfoKind.Prim or _switchExp == TypeInfoKind.List or _switchExp == TypeInfoKind.Array or _switchExp == TypeInfoKind.Map or _switchExp == TypeInfoKind.Class or _switchExp == TypeInfoKind.Stem or _switchExp == TypeInfoKind.Module or _switchExp == TypeInfoKind.IF then
        hasNilable = true
      elseif _switchExp == TypeInfoKind.Func or _switchExp == TypeInfoKind.Method then
        hasNilable = true
      end
    end
    
    if hasNilable then
      if txt == "..." then
        self.nilableTypeInfo = self
      else 
        self.nilableTypeInfo = NilableTypeInfo.new(self, typeId + 1)
        idProv:increment(  )
      end
    else 
      self.nilableTypeInfo = _moduleObj.headTypeInfo
    end
    idProv:increment(  )
  else 
    self.nilable = true
    self.nilableTypeInfo = _moduleObj.headTypeInfo
  end
end
function NormalTypeInfo:isModule(  )
  return false
end
function NormalTypeInfo:getParentId(  )
  return self.parentInfo:get_typeId() or _moduleObj.rootTypeId
end
function NormalTypeInfo:get_baseId(  )
  return self.baseTypeInfo:get_typeId() or _moduleObj.rootTypeId
end
function NormalTypeInfo:getTxt(  )
  if self.nilable and (self.nilableTypeInfo ~= self.orgTypeInfo ) then
    return (_lune.unwrap( self.orgTypeInfo) ):getTxt(  ) .. "!"
  end
  if #self.itemTypeInfoList > 0 then
    local txt = self.rawTxt .. "<"
    
    for index, typeInfo in pairs( self.itemTypeInfoList ) do
      if index ~= 1 then
        txt = txt .. ","
      end
      txt = txt .. typeInfo:getTxt(  )
    end
    return txt .. ">"
  end
  if self:get_rawTxt() then
    return self:get_rawTxt()
  end
  return ""
end
function NormalTypeInfo:get_display_stirng(  )
  if self.kind == TypeInfoKind.Nilable then
    return (_lune.unwrap( self.orgTypeInfo) ):get_display_stirng(  ) .. "!"
  end
  if self.kind == TypeInfoKind.Func or self.kind == TypeInfoKind.Method then
    local txt = self:get_rawTxt() .. "("
    
    for index, argType in pairs( self.argTypeInfoList ) do
      if index ~= 1 then
        txt = txt .. ", "
      end
      txt = txt .. argType:get_display_stirng(  )
    end
    txt = txt .. ")"
    for index, retType in pairs( self.retTypeInfoList ) do
      if index == 1 then
        txt = txt .. ": "
      else 
        txt = txt .. ", "
      end
      txt = txt .. retType:get_display_stirng(  )
    end
    return txt
  end
  return self:getTxt(  )
end
function NormalTypeInfo:serialize( stream, validChildrenSet )
  if self.typeId == _moduleObj.rootTypeId then
    return 
  end
  local parentId = self:getParentId(  )
  
  if self.nilable then
    stream:write( string.format( '{ parentId = %d, typeId = %d, nilable = true, orgTypeId = %d }\n', parentId, self.typeId, self.orgTypeInfo:get_typeId()) )
    return 
  end
  local function serializeTypeInfoList( name, list, onlyPub )
    local work = name
    
    for __index, typeInfo in pairs( list ) do
      if not onlyPub or typeInfo:get_accessMode() == AccessMode.Pub then
        if #work ~= #name then
          work = work .. ", "
        end
        work = string.format( "%s%d", work, typeInfo:get_typeId())
      end
    end
    return work .. "}, "
  end
  
  local txt = string.format( [==[{ parentId = %d, typeId = %d, baseId = %d, txt = '%s',
        staticFlag = %s, accessMode = %d, kind = %d, mutable = %s, ]==], parentId, self.typeId, self:get_baseId(  ), self.rawTxt, self.staticFlag, self.accessMode, self.kind, self.mutable)
  
  local children = {}
  
  local set = validChildrenSet
  
      if  nil == set then
        local _set = set
        
        set = {}
      end
    
  for __index, child in pairs( self:get_children() ) do
    if set[child:get_typeId()] then
      table.insert( children, child )
    end
  end
  stream:write( txt .. serializeTypeInfoList( "itemTypeId = {", self.itemTypeInfoList ) .. serializeTypeInfoList( "ifList = {", self.interfaceList ) .. serializeTypeInfoList( "argTypeId = {", self.argTypeInfoList ) .. serializeTypeInfoList( "retTypeId = {", self.retTypeInfoList ) .. serializeTypeInfoList( "children = {", children, true ) .. "}\n" )
end
function NormalTypeInfo:equalsSub( typeInfo )
  typeInfo = typeInfo:get_srcTypeInfo()
  if self.typeId == typeInfo:get_typeId() then
    return true
  end
  if self.kind ~= typeInfo:get_kind() or self.staticFlag ~= typeInfo:get_staticFlag() or self.accessMode ~= typeInfo:get_accessMode() or self.autoFlag ~= typeInfo:get_autoFlag() or self.nilable ~= typeInfo:get_nilable() or self.rawTxt ~= typeInfo:get_rawTxt() or self.parentInfo ~= typeInfo:get_parentInfo() or self.baseTypeInfo ~= typeInfo:get_baseTypeInfo() or self ~= typeInfo:get_srcTypeInfo() then
    return false
  end
  if (self.orgTypeInfo ~= typeInfo:get_orgTypeInfo() ) then
    Util.log( string.format( "%s, %s", self.orgTypeInfo, typeInfo:get_orgTypeInfo()) )
    return false
  end
  if self.itemTypeInfoList then
    if #self.itemTypeInfoList ~= #typeInfo:get_itemTypeInfoList() then
      return false
    end
    for index, item in pairs( self.itemTypeInfoList ) do
      if not item:equals( typeInfo:get_itemTypeInfoList()[index] ) then
        return false
      end
    end
  end
  if self.retTypeInfoList then
    if #self.retTypeInfoList ~= #typeInfo:get_retTypeInfoList() then
      return false
    end
    for index, item in pairs( self.retTypeInfoList ) do
      if not item:equals( typeInfo:get_retTypeInfoList()[index] ) then
        return false
      end
    end
  end
  if self.orgTypeInfo ~= _moduleObj.headTypeInfo and not self.orgTypeInfo:equals( typeInfo:get_orgTypeInfo() ) then
    error( string.format( "illegal %s:%d %s:%d", self:getTxt(  ), self.typeId, typeInfo:getTxt(  ), typeInfo:get_typeId()) )
    return false
  end
  return true
end
function NormalTypeInfo:equals( typeInfo )
  return self:equalsSub( typeInfo )
end
function NormalTypeInfo.create( abstructFlag, scope, baseInfo, interfaceList, parentInfo, staticFlag, kind, txt, itemTypeInfo, argTypeInfoList, retTypeInfoList, mutable )
  if kind == TypeInfoKind.Prim then
    do
      local _exp = _moduleObj.sym2builtInTypeMap[txt]
      if _exp ~= nil then
      
          return _exp:get_typeInfo()
        end
    end
    
    Util.err( string.format( "not found symbol -- %s", txt) )
  end
  idProv:increment(  )
  local info = NormalTypeInfo.new(abstructFlag, scope, baseInfo, interfaceList, nil, false, true, staticFlag, AccessMode.Pub, txt, parentInfo, idProv:get_id(), kind, itemTypeInfo, argTypeInfoList, retTypeInfoList, mutable)
  
  return info
end
function NormalTypeInfo.setmeta( obj )
  setmetatable( obj, { __index = NormalTypeInfo  } )
end
function NormalTypeInfo:get_externalFlag()       
  return self.externalFlag         
end
function NormalTypeInfo:get_itemTypeInfoList()       
  return self.itemTypeInfoList         
end
function NormalTypeInfo:get_argTypeInfoList()       
  return self.argTypeInfoList         
end
function NormalTypeInfo:get_retTypeInfoList()       
  return self.retTypeInfoList         
end
function NormalTypeInfo:get_parentInfo()       
  return self.parentInfo         
end
function NormalTypeInfo:get_typeId()       
  return self.typeId         
end
function NormalTypeInfo:get_rawTxt()       
  return self.rawTxt         
end
function NormalTypeInfo:get_kind()       
  return self.kind         
end
function NormalTypeInfo:get_staticFlag()       
  return self.staticFlag         
end
function NormalTypeInfo:get_accessMode()       
  return self.accessMode         
end
function NormalTypeInfo:get_autoFlag()       
  return self.autoFlag         
end
function NormalTypeInfo:get_abstructFlag()       
  return self.abstructFlag         
end
function NormalTypeInfo:get_orgTypeInfo()       
  return self.orgTypeInfo         
end
function NormalTypeInfo:get_baseTypeInfo()       
  return self.baseTypeInfo         
end
function NormalTypeInfo:get_interfaceList()       
  return self.interfaceList         
end
function NormalTypeInfo:get_nilable()       
  return self.nilable         
end
function NormalTypeInfo:get_nilableTypeInfo()       
  return self.nilableTypeInfo         
end
function NormalTypeInfo:get_mutable()       
  return self.mutable         
end
do
  end

idProv:increment(  )
function NormalTypeInfo.createBuiltin( idName, typeTxt, kind, typeDDD )
  local typeId = idProv:get_id() + 1
  
  if kind == TypeInfoKind.Root then
    typeId = _moduleObj.rootTypeId
  else 
    idProv:increment(  )
  end
  local argTypeList = {}
  
  local retTypeList = {}
  
  if typeTxt == "form" then
    do
      local _exp = typeDDD
      if _exp ~= nil then
      
          argTypeList = {_exp}
          retTypeList = {_exp}
        end
    end
    
  end
  local scope = nil
  
  do
    local _switchExp = kind
    if _switchExp == TypeInfoKind.List or _switchExp == TypeInfoKind.Class or _switchExp == TypeInfoKind.Module or _switchExp == TypeInfoKind.IF or _switchExp == TypeInfoKind.Func or _switchExp == TypeInfoKind.Method or _switchExp == TypeInfoKind.Macro then
      scope = Scope.new(_moduleObj.rootScope, kind == TypeInfoKind.Class or kind == TypeInfoKind.Module or kind == TypeInfoKind.IF or kind == TypeInfoKind.List, {})
    end
  end
  
  local info = NormalTypeInfo.new(false, scope, nil, nil, nil, false, false, false, AccessMode.Pub, typeTxt, _moduleObj.headTypeInfo, typeId, kind, {}, argTypeList, retTypeList, true)
  
  if scope then
    _moduleObj.rootScope:addClass( typeTxt, info )
  end
  _moduleObj.typeInfoKind[idName] = info
  _moduleObj.sym2builtInTypeMap[typeTxt] = NormalSymbolInfo.new(SymbolKind.Typ, false, false, _moduleObj.rootScope, AccessMode.Pub, false, typeTxt, info, false, true)
  if info:get_nilableTypeInfo() ~= _moduleObj.headTypeInfo then
    _moduleObj.sym2builtInTypeMap[typeTxt .. "!"] = NormalSymbolInfo.new(SymbolKind.Typ, false, kind == TypeInfoKind.Func, _moduleObj.rootScope, AccessMode.Pub, false, typeTxt, info:get_nilableTypeInfo(), false, true)
    _moduleObj.builtInTypeIdSet[info:get_nilableTypeInfo():get_typeId()] = info:get_nilableTypeInfo()
  end
  _moduleObj.builtInTypeIdSet[info.typeId] = info
  return info
end

function NormalTypeInfo.createList( accessMode, parentInfo, itemTypeInfo )
  if #itemTypeInfo == 0 then
    Util.err( string.format( "illegal list type: %s", itemTypeInfo) )
  end
  idProv:increment(  )
  return NormalTypeInfo.new(false, nil, nil, nil, nil, false, false, false, accessMode, "List", _moduleObj.headTypeInfo, idProv:get_id(), TypeInfoKind.List, itemTypeInfo, nil, nil, true)
end

function NormalTypeInfo.createArray( accessMode, parentInfo, itemTypeInfo )
  idProv:increment(  )
  return NormalTypeInfo.new(false, nil, nil, nil, nil, false, false, false, accessMode, "Array", _moduleObj.headTypeInfo, idProv:get_id(), TypeInfoKind.Array, itemTypeInfo, nil, nil, true)
end

function NormalTypeInfo.createMap( accessMode, parentInfo, keyTypeInfo, valTypeInfo )
  idProv:increment(  )
  return NormalTypeInfo.new(false, nil, nil, nil, nil, false, false, false, accessMode, "Map", _moduleObj.headTypeInfo, idProv:get_id(), TypeInfoKind.Map, {keyTypeInfo, valTypeInfo}, nil, nil, true)
end

function NormalTypeInfo.createModule( scope, parentInfo, externalFlag, moduleName, mutable )
  do
    local _exp = _moduleObj.sym2builtInTypeMap[moduleName]
    if _exp ~= nil then
    
        return _exp:get_typeInfo()
      end
  end
  
  if Parser.isLuaKeyword( moduleName ) then
    Util.err( string.format( "This symbol can not use for a class or script file. -- %s", moduleName) )
  end
  idProv:increment(  )
  local info = ModuleTypeInfo.new(scope, externalFlag, moduleName, parentInfo, idProv:get_id(), mutable)
  
  return info
end

function NormalTypeInfo.createClass( classFlag, abstructFlag, scope, baseInfo, interfaceList, parentInfo, externalFlag, accessMode, className )
  do
    local _exp = _moduleObj.sym2builtInTypeMap[className]
    if _exp ~= nil then
    
        return _exp:get_typeInfo()
      end
  end
  
  if Parser.isLuaKeyword( className ) then
    Util.err( string.format( "This symbol can not use for a class or script file. -- %s", className) )
  end
  idProv:increment(  )
  local info = NormalTypeInfo.new(abstructFlag, scope, baseInfo, interfaceList, nil, false, externalFlag, false, accessMode, className, parentInfo, idProv:get_id(), classFlag and TypeInfoKind.Class or TypeInfoKind.IF, nil, nil, nil, true)
  
  return info
end

function NormalTypeInfo.createFunc( abstructFlag, builtinFlag, scope, kind, parentInfo, autoFlag, externalFlag, staticFlag, accessMode, funcName, argTypeList, retTypeInfoList, mutable )
  if not builtinFlag and Parser.isLuaKeyword( funcName ) then
    Util.err( string.format( "This symbol can not use for a function. -- %s", funcName) )
  end
  idProv:increment(  )
  local info = NormalTypeInfo.new(abstructFlag, scope, nil, nil, nil, autoFlag, externalFlag, staticFlag, accessMode, funcName, parentInfo, idProv:get_id(), kind, {}, _lune.unwrapDefault( argTypeList, {}), _lune.unwrapDefault( retTypeInfoList, {}), mutable)
  
  return info
end

function NormalTypeInfo.createAdvertiseMethodFrom( classTypeInfo, typeInfo )
  return NormalTypeInfo.createFunc( false, false, typeInfo:get_scope(), typeInfo:get_kind(), classTypeInfo, true, false, false, typeInfo:get_accessMode(), typeInfo:get_rawTxt(), typeInfo:get_argTypeInfoList(), typeInfo:get_retTypeInfoList(), typeInfo:get_mutable() )
end

local typeInfo2ModifierMap = {}

function NormalTypeInfo.createModifier( srcTypeInfo, mutable )
  do
    local _exp = typeInfo2ModifierMap[srcTypeInfo]
    if _exp ~= nil then
    
        return _exp
      end
  end
  
  idProv:increment(  )
  local modifier = ModifierTypeInfo.new(srcTypeInfo, idProv:get_id(), mutable)
  
  typeInfo2ModifierMap[srcTypeInfo] = modifier
  return modifier
end

local builtinTypeNone = NormalTypeInfo.createBuiltin( "None", "", TypeInfoKind.Prim )

_moduleObj.builtinTypeNone = builtinTypeNone

local builtinTypeStem = NormalTypeInfo.createBuiltin( "Stem", "stem", TypeInfoKind.Stem )

_moduleObj.builtinTypeStem = builtinTypeStem

local builtinTypeNil = NormalTypeInfo.createBuiltin( "Nil", "nil", TypeInfoKind.Prim )

_moduleObj.builtinTypeNil = builtinTypeNil

local builtinTypeDDD = NormalTypeInfo.createBuiltin( "DDD", "...", TypeInfoKind.Prim )

_moduleObj.builtinTypeDDD = builtinTypeDDD

local builtinTypeBool = NormalTypeInfo.createBuiltin( "Bool", "bool", TypeInfoKind.Prim )

_moduleObj.builtinTypeBool = builtinTypeBool

local builtinTypeInt = NormalTypeInfo.createBuiltin( "Int", "int", TypeInfoKind.Prim )

_moduleObj.builtinTypeInt = builtinTypeInt

local builtinTypeReal = NormalTypeInfo.createBuiltin( "Real", "real", TypeInfoKind.Prim )

_moduleObj.builtinTypeReal = builtinTypeReal

local builtinTypeChar = NormalTypeInfo.createBuiltin( "char", "char", TypeInfoKind.Prim )

_moduleObj.builtinTypeChar = builtinTypeChar

local builtinTypeString = NormalTypeInfo.createBuiltin( "String", "str", TypeInfoKind.Class )

_moduleObj.builtinTypeString = builtinTypeString

local builtinTypeMap = NormalTypeInfo.createBuiltin( "Map", "Map", TypeInfoKind.Map )

_moduleObj.builtinTypeMap = builtinTypeMap

local builtinTypeList = NormalTypeInfo.createBuiltin( "List", "List", TypeInfoKind.List )

_moduleObj.builtinTypeList = builtinTypeList

local builtinTypeArray = NormalTypeInfo.createBuiltin( "Array", "Array", TypeInfoKind.Array )

_moduleObj.builtinTypeArray = builtinTypeArray

local builtinTypeForm = NormalTypeInfo.createBuiltin( "Form", "form", TypeInfoKind.Func, _moduleObj.builtinTypeDDD )

_moduleObj.builtinTypeForm = builtinTypeForm

local builtinTypeSymbol = NormalTypeInfo.createBuiltin( "Symbol", "sym", TypeInfoKind.Prim )

_moduleObj.builtinTypeSymbol = builtinTypeSymbol

local builtinTypeStat = NormalTypeInfo.createBuiltin( "Stat", "stat", TypeInfoKind.Prim )

_moduleObj.builtinTypeStat = builtinTypeStat

local builtinTypeStem_ = _lune.unwrap( _moduleObj.builtinTypeStem:get_nilableTypeInfo())

_moduleObj.builtinTypeStem_ = builtinTypeStem_

function NormalTypeInfo.createEnum( scope, parentInfo, externalFlag, accessMode, enumName, valTypeInfo, name2EnumValInfo )
  if Parser.isLuaKeyword( enumName ) then
    Util.err( string.format( "This symbol can not use for a enum. -- %s", enumName) )
  end
  idProv:increment(  )
  local info = EnumTypeInfo.new(scope, externalFlag, accessMode, enumName, parentInfo, idProv:get_id(), valTypeInfo, name2EnumValInfo)
  
  local getEnumName = NormalTypeInfo.createFunc( false, true, nil, TypeInfoKind.Method, info, true, true, false, AccessMode.Pub, "get__txt", nil, {_moduleObj.builtinTypeString}, false )
  
  scope:addMethod( getEnumName, AccessMode.Pub, false, true )
  local fromVal = NormalTypeInfo.createFunc( false, true, nil, TypeInfoKind.Method, info, true, true, true, AccessMode.Pub, "_from", {NormalTypeInfo.createModifier( valTypeInfo, false )}, {info:get_nilableTypeInfo()}, false )
  
  scope:addMethod( fromVal, AccessMode.Pub, true, true )
  return info
end

function EnumTypeInfo:serialize( stream, validChildrenSet )
  local txt = string.format( [==[{ parentId = %d, typeId = %d, txt = '%s',
accessMode = %d, kind = %d, valTypeId = %d, ]==], self:getParentId(  ), self.typeId, self.rawTxt, self.accessMode, TypeInfoKind.Enum, self.valTypeInfo:get_typeId())
  
  stream:write( txt )
  stream:write( "enumValList = {" )
  do
    local __sorted = {}
    local __map = self.name2EnumValInfo
    for __key in pairs( __map ) do
      table.insert( __sorted, __key )
    end
    table.sort( __sorted )
    for __index, __key in ipairs( __sorted ) do
      enumValInfo = __map[ __key ]
      do
        if self.valTypeInfo:equals( _moduleObj.builtinTypeString ) then
          stream:write( string.format( "%s = '%s',", enumValInfo:get_name(), enumValInfo:get_val()) )
        else 
          stream:write( string.format( "%s = %s,", enumValInfo:get_name(), enumValInfo:get_val()) )
        end
      end
    end
  end
  
  stream:write( "} }\n" )
end

function NilableTypeInfo:canEvalWith( other, opTxt )
  local otherSrc = other:get_srcTypeInfo()
  
  if self == _moduleObj.builtinTypeStem_ then
    return true
  end
  if otherSrc == _moduleObj.builtinTypeNil then
    return true
  end
  if self.typeId == otherSrc:get_typeId() then
    return true
  end
  if otherSrc:get_nilable() then
    return self:get_orgTypeInfo():canEvalWith( otherSrc:get_orgTypeInfo(), opTxt )
  end
  return self:get_orgTypeInfo():canEvalWith( otherSrc, opTxt )
end


-- none

function NormalTypeInfo:isInheritFrom( other )
  local otherTypeId = other:get_typeId()
  
  if self:get_typeId() == otherTypeId then
    return true
  end
  if (self:get_kind() ~= TypeInfoKind.Class and self:get_kind() ~= TypeInfoKind.IF ) or (other:get_kind() ~= TypeInfoKind.Class and other:get_kind() ~= TypeInfoKind.IF ) then
    return false
  end
  local baseTypeInfo = self:get_baseTypeInfo()
  
  while baseTypeInfo ~= _moduleObj.headTypeInfo do
    if otherTypeId == baseTypeInfo:get_typeId() then
      return true
    end
    baseTypeInfo = baseTypeInfo:get_baseTypeInfo()
  end
  -- none
  
  for __index, ifType in pairs( self:get_interfaceList() ) do
    local workType = ifType
    
    while workType ~= _moduleObj.headTypeInfo do
      if otherTypeId == workType:get_typeId() then
        return true
      end
      workType = workType:get_baseTypeInfo()
    end
    -- none
    
  end
  return false
end

function TypeInfo.checkMatchType( dstTypeList, expTypeList, allowDstShort )
  if #expTypeList > 0 then
    for index, expType in pairs( expTypeList ) do
      if #dstTypeList == 0 then
        return false, string.format( "over exp. expect:0, actual:%d", #expTypeList)
      end
      local argType = dstTypeList[index]
      
      if #dstTypeList == index then
        if not argType:equals( _moduleObj.builtinTypeDDD ) then
          if not argType:canEvalWith( expType, "=" ) then
            return false, string.format( "exp(%d) type mismatch %s <- %s", index, argType:getTxt(  ), expType:getTxt(  ))
          end
          if not allowDstShort and #dstTypeList < #expTypeList then
            return false, string.format( "over exp. expect: %d: actual: %d", #dstTypeList, #expTypeList)
          end
        end
        break
      elseif #expTypeList == index then
        if expType:equals( _moduleObj.builtinTypeDDD ) then
          for argIndex = index, #dstTypeList do
            local workArgType = dstTypeList[argIndex]
            
            if not workArgType:canEvalWith( _moduleObj.builtinTypeStem_, "=" ) then
              return false, string.format( "exp(%d) type mismatch %s <- %s", argIndex, workArgType:getTxt(  ), _moduleObj.builtinTypeStem_:getTxt(  ))
            end
          end
        else 
          local workExpType = expType
          
          for argIndex = index, #dstTypeList do
            local argTypeInfo = dstTypeList[argIndex]
            
            if not argTypeInfo:canEvalWith( workExpType, "=" ) then
              return false, string.format( "exp(%d) type mismatch %s <- %s", argIndex, argTypeInfo:getTxt(  ), workExpType:getTxt(  ))
            end
            workExpType = _moduleObj.builtinTypeNil
          end
        end
        break
      else 
        if not argType:canEvalWith( expType, "=" ) then
          return false, string.format( "exp(%d) type mismatch %s <- %s", index, argType:getTxt(  ), expType:getTxt(  ))
        end
      end
    end
  elseif not allowDstShort then
    for index, argType in pairs( dstTypeList ) do
      if not argType:canEvalWith( _moduleObj.builtinTypeNil, "=" ) then
        return false, string.format( "exp(%d) type mismatch %s <- nil", index, argType:getTxt(  ))
      end
    end
  end
  return true, ""
end

function TypeInfo.canEvalWithBase( dist, distMut, other, opTxt )
  local otherMut = other:get_mutable()
  
  local otherSrc = other:get_srcTypeInfo()
  
  if opTxt == "=" and otherSrc ~= _moduleObj.builtinTypeNil and otherSrc ~= _moduleObj.builtinTypeString and otherSrc:get_kind() ~= TypeInfoKind.Prim and otherSrc:get_kind() ~= TypeInfoKind.Func and otherSrc:get_kind() ~= TypeInfoKind.Enum and distMut and not otherMut then
    return false
  end
  if dist == _moduleObj.builtinTypeStem_ or dist == _moduleObj.builtinTypeDDD then
    return true
  end
  if not dist:get_nilable() and otherSrc:get_nilable() then
    return false
  end
  if dist == _moduleObj.builtinTypeStem and not otherSrc:get_nilable() then
    return true
  end
  if dist == _moduleObj.builtinTypeForm and otherSrc:get_kind() == TypeInfoKind.Func then
    return true
  end
  if otherSrc == _moduleObj.builtinTypeNil then
    if dist:get_kind() ~= TypeInfoKind.Nilable then
      return false
    end
    return true
  end
  if dist:get_typeId() == otherSrc:get_typeId() then
    return true
  end
  if dist:get_kind() ~= otherSrc:get_kind() then
    if dist:get_kind() == TypeInfoKind.Nilable then
      if otherSrc:get_nilable() then
        return dist:get_orgTypeInfo():canEvalWith( otherSrc:get_orgTypeInfo(), opTxt )
      end
      return dist:get_orgTypeInfo():canEvalWith( otherSrc, opTxt )
    elseif (dist:get_kind() == TypeInfoKind.Class or dist:get_kind() == TypeInfoKind.IF ) and (otherSrc:get_kind() == TypeInfoKind.Class or otherSrc:get_kind() == TypeInfoKind.IF ) then
      return otherSrc:isInheritFrom( dist )
    elseif otherSrc:get_kind() == TypeInfoKind.Enum then
      local enumTypeInfo = otherSrc
      
      return dist:canEvalWith( enumTypeInfo:get_valTypeInfo(), opTxt )
    end
    return false
  end
  do
    local _switchExp = (dist:get_kind() )
    if _switchExp == TypeInfoKind.Prim then
      if dist == _moduleObj.builtinTypeInt and otherSrc == _moduleObj.builtinTypeChar or dist == _moduleObj.builtinTypeChar and otherSrc == _moduleObj.builtinTypeInt then
        return true
      end
      return false
    elseif _switchExp == TypeInfoKind.List or _switchExp == TypeInfoKind.Array then
      if otherSrc:get_itemTypeInfoList()[1] == _moduleObj.builtinTypeNone then
        return true
      end
      if not (_lune.unwrap( dist:get_itemTypeInfoList()[1]) ):canEvalWith( _lune.unwrap( otherSrc:get_itemTypeInfoList()[1]), "=" ) then
        return false
      end
      
      return true
    elseif _switchExp == TypeInfoKind.Map then
      if otherSrc:get_itemTypeInfoList()[1] == _moduleObj.builtinTypeNone and otherSrc:get_itemTypeInfoList()[2] == _moduleObj.builtinTypeNone then
        return true
      end
      if not (_lune.unwrap( dist:get_itemTypeInfoList()[1]) ):canEvalWith( _lune.unwrap( otherSrc:get_itemTypeInfoList()[1]), "=" ) then
        return false
      end
      
      if not (_lune.unwrap( dist:get_itemTypeInfoList()[2]) ):canEvalWith( _lune.unwrap( otherSrc:get_itemTypeInfoList()[2]), "=" ) then
        return false
      end
      
      return true
    elseif _switchExp == TypeInfoKind.Class or _switchExp == TypeInfoKind.IF then
      return otherSrc:isInheritFrom( dist )
    elseif _switchExp == TypeInfoKind.Func then
      if dist == _moduleObj.builtinTypeForm then
        return true
      end
      if not TypeInfo.checkMatchType( dist:get_argTypeInfoList(), otherSrc:get_argTypeInfoList(), false ) or not TypeInfo.checkMatchType( dist:get_retTypeInfoList(), otherSrc:get_retTypeInfoList(), false ) then
        return false
      end
      return true
    elseif _switchExp == TypeInfoKind.Method then
      if not TypeInfo.checkMatchType( dist:get_argTypeInfoList(), otherSrc:get_argTypeInfoList(), false ) or not TypeInfo.checkMatchType( dist:get_retTypeInfoList(), otherSrc:get_retTypeInfoList(), false ) then
        return false
      end
      return true
    elseif _switchExp == TypeInfoKind.Nilable then
      return dist:get_orgTypeInfo():canEvalWith( otherSrc:get_orgTypeInfo(), opTxt )
    else 
      return false
    end
  end
  
  return true
end

function NormalTypeInfo:canEvalWith( other, opTxt )
  return TypeInfo.canEvalWithBase( self, self:get_mutable(), other, opTxt )
end

local Filter = {}
_moduleObj.Filter = Filter
function Filter.setmeta( obj )
  setmetatable( obj, { __index = Filter  } )
end
function Filter.new(  )
  local obj = {}
  Filter.setmeta( obj )
  if obj.__init then
    obj:__init(  )
  end        
  return obj 
end         
function Filter:__init(  ) 

end
do
  end

local Node = {}
_moduleObj.Node = Node
function Node:get_expType(  )
  if #self.expTypeList == 0 then
    return _moduleObj.builtinTypeNone
  end
  return self.expTypeList[1]
end
function Node:getLiteral(  )
  return {nil}, {_moduleObj.builtinTypeNil}
end
function Node:processFilter( filter, ... )
end
function Node:canBeLeft(  )
  return false
end
function Node:canBeRight(  )
  return false
end
function Node.setmeta( obj )
  setmetatable( obj, { __index = Node  } )
end
function Node.new( kind, pos, expTypeList )
  local obj = {}
  Node.setmeta( obj )
  if obj.__init then
    obj:__init( kind, pos, expTypeList )
  end        
  return obj 
end         
function Node:__init( kind, pos, expTypeList ) 

self.kind = kind
  self.pos = pos
  self.expTypeList = expTypeList
  end
function Node:get_kind()       
  return self.kind         
end
function Node:get_pos()       
  return self.pos         
end
function Node:get_expTypeList()       
  return self.expTypeList         
end
do
  end

local NamespaceInfo = {}
_moduleObj.NamespaceInfo = NamespaceInfo
function NamespaceInfo.setmeta( obj )
  setmetatable( obj, { __index = NamespaceInfo  } )
end
function NamespaceInfo.new( name, scope, typeInfo )
  local obj = {}
  NamespaceInfo.setmeta( obj )
  if obj.__init then
    obj:__init( name, scope, typeInfo )
  end        
  return obj 
end         
function NamespaceInfo:__init( name, scope, typeInfo ) 

self.name = name
  self.scope = scope
  self.typeInfo = typeInfo
  end
do
  end

-- none

-- none

-- none

local DeclMacroInfo = {}
_moduleObj.DeclMacroInfo = DeclMacroInfo
function DeclMacroInfo.setmeta( obj )
  setmetatable( obj, { __index = DeclMacroInfo  } )
end
function DeclMacroInfo.new( name, argList, ast, tokenList )
  local obj = {}
  DeclMacroInfo.setmeta( obj )
  if obj.__init then
    obj:__init( name, argList, ast, tokenList )
  end        
  return obj 
end         
function DeclMacroInfo:__init( name, argList, ast, tokenList ) 

self.name = name
  self.argList = argList
  self.ast = ast
  self.tokenList = tokenList
  end
function DeclMacroInfo:get_name()       
  return self.name         
end
function DeclMacroInfo:get_argList()       
  return self.argList         
end
function DeclMacroInfo:get_ast()       
  return self.ast         
end
function DeclMacroInfo:get_tokenList()       
  return self.tokenList         
end
do
  end

local MacroValInfo = {}
_moduleObj.MacroValInfo = MacroValInfo
function MacroValInfo.setmeta( obj )
  setmetatable( obj, { __index = MacroValInfo  } )
end
function MacroValInfo.new( val, typeInfo )
  local obj = {}
  MacroValInfo.setmeta( obj )
  if obj.__init then
    obj:__init( val, typeInfo )
  end        
  return obj 
end         
function MacroValInfo:__init( val, typeInfo ) 

self.val = val
  self.typeInfo = typeInfo
  end
do
  end

local MacroInfo = {}
_moduleObj.MacroInfo = MacroInfo
function MacroInfo.setmeta( obj )
  setmetatable( obj, { __index = MacroInfo  } )
end
function MacroInfo.new( func, declInfo, symbol2MacroValInfoMap )
  local obj = {}
  MacroInfo.setmeta( obj )
  if obj.__init then
    obj:__init( func, declInfo, symbol2MacroValInfoMap )
  end        
  return obj 
end         
function MacroInfo:__init( func, declInfo, symbol2MacroValInfoMap ) 

self.func = func
  self.declInfo = declInfo
  self.symbol2MacroValInfoMap = symbol2MacroValInfoMap
  end
do
  end

local nodeKind2NameMap = {}

local nodeKindSeed = 1

local nodeKind = {}

_moduleObj.nodeKind = nodeKind

local function regKind( name )
  local kind = nodeKindSeed
  
  nodeKindSeed = nodeKindSeed + 1
  nodeKind2NameMap[kind] = name
  _moduleObj.nodeKind[name] = kind
  return kind
end

local function getNodeKindName( kind )
  return _lune.unwrap( nodeKind2NameMap[kind])
end
_moduleObj.getNodeKindName = getNodeKindName

-- none

function Filter:processNone( node, ... )
end

-- none

-- none

local nodeKindNone = regKind( [[None]] )

_moduleObj.nodeKindNone = nodeKindNone

local NoneNode = {}
setmetatable( NoneNode, { __index = Node } )
_moduleObj.NoneNode = NoneNode
function NoneNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processNone( self, table.unpack( argList ) )
end
function NoneNode:canBeRight(  )
  return false
end
function NoneNode:canBeLeft(  )
  return false
end
function NoneNode.new( pos, typeList )
  local obj = {}
  NoneNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList ); end
return obj
end
function NoneNode:__init(pos, typeList) 
  Node.__init( self, _moduleObj.nodeKindNone, pos, typeList)
  
  -- none
  
  -- none
  
end
function NoneNode.setmeta( obj )
  setmetatable( obj, { __index = NoneNode  } )
end
do
  end


-- none

function Filter:processSubfile( node, ... )
end

-- none

-- none

local nodeKindSubfile = regKind( [[Subfile]] )

_moduleObj.nodeKindSubfile = nodeKindSubfile

local SubfileNode = {}
setmetatable( SubfileNode, { __index = Node } )
_moduleObj.SubfileNode = SubfileNode
function SubfileNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processSubfile( self, table.unpack( argList ) )
end
function SubfileNode:canBeRight(  )
  return false
end
function SubfileNode:canBeLeft(  )
  return false
end
function SubfileNode.new( pos, typeList )
  local obj = {}
  SubfileNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList ); end
return obj
end
function SubfileNode:__init(pos, typeList) 
  Node.__init( self, _moduleObj.nodeKindSubfile, pos, typeList)
  
  -- none
  
  -- none
  
end
function SubfileNode.setmeta( obj )
  setmetatable( obj, { __index = SubfileNode  } )
end
do
  end


-- none

function Filter:processImport( node, ... )
end

-- none

-- none

local nodeKindImport = regKind( [[Import]] )

_moduleObj.nodeKindImport = nodeKindImport

local ImportNode = {}
setmetatable( ImportNode, { __index = Node } )
_moduleObj.ImportNode = ImportNode
function ImportNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processImport( self, table.unpack( argList ) )
end
function ImportNode:canBeRight(  )
  return false
end
function ImportNode:canBeLeft(  )
  return false
end
function ImportNode.new( pos, typeList, modulePath, moduleTypeInfo )
  local obj = {}
  ImportNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, modulePath, moduleTypeInfo ); end
return obj
end
function ImportNode:__init(pos, typeList, modulePath, moduleTypeInfo) 
  Node.__init( self, _moduleObj.nodeKindImport, pos, typeList)
  
  -- none
  
  self.modulePath = modulePath
  self.moduleTypeInfo = moduleTypeInfo
  -- none
  
end
function ImportNode.setmeta( obj )
  setmetatable( obj, { __index = ImportNode  } )
end
function ImportNode:get_modulePath()       
  return self.modulePath         
end
function ImportNode:get_moduleTypeInfo()       
  return self.moduleTypeInfo         
end
do
  end


-- none

local LuneHelperInfo = {}
_moduleObj.LuneHelperInfo = LuneHelperInfo
function LuneHelperInfo.setmeta( obj )
  setmetatable( obj, { __index = LuneHelperInfo  } )
end
function LuneHelperInfo.new( useNilAccess, useUnwrapExp )
  local obj = {}
  LuneHelperInfo.setmeta( obj )
  if obj.__init then
    obj:__init( useNilAccess, useUnwrapExp )
  end        
  return obj 
end         
function LuneHelperInfo:__init( useNilAccess, useUnwrapExp ) 

self.useNilAccess = useNilAccess
  self.useUnwrapExp = useUnwrapExp
  end
function LuneHelperInfo:get_useNilAccess()       
  return self.useNilAccess         
end
function LuneHelperInfo:get_useUnwrapExp()       
  return self.useUnwrapExp         
end
do
  end

local ModuleInfo = {}
_moduleObj.ModuleInfo = ModuleInfo
function ModuleInfo.new( fullName, idMap )
  local obj = {}
  ModuleInfo.setmeta( obj )
  if obj.__init then obj:__init( fullName, idMap ); end
return obj
end
function ModuleInfo:__init(fullName, idMap) 
  self.fullName = fullName
  self.localTypeInfo2importIdMap = idMap
  self.importId2localTypeInfoMap = {}
  for typeInfo, importId in pairs( idMap ) do
    self.importId2localTypeInfoMap[importId] = typeInfo
  end
end
function ModuleInfo.setmeta( obj )
  setmetatable( obj, { __index = ModuleInfo  } )
end
function ModuleInfo:get_fullName()       
  return self.fullName         
end
function ModuleInfo:get_localTypeInfo2importIdMap()       
  return self.localTypeInfo2importIdMap         
end
function ModuleInfo:get_importId2localTypeInfoMap()       
  return self.importId2localTypeInfoMap         
end
do
  end

-- none

function Filter:processRoot( node, ... )
end

-- none

-- none

local nodeKindRoot = regKind( [[Root]] )

_moduleObj.nodeKindRoot = nodeKindRoot

local RootNode = {}
setmetatable( RootNode, { __index = Node } )
_moduleObj.RootNode = RootNode
function RootNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processRoot( self, table.unpack( argList ) )
end
function RootNode:canBeRight(  )
  return false
end
function RootNode:canBeLeft(  )
  return false
end
function RootNode.new( pos, typeList, children, moduleTypeInfo, provideNode, luneHelperInfo, importModule2moduleInfo, typeId2ClassMap )
  local obj = {}
  RootNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, children, moduleTypeInfo, provideNode, luneHelperInfo, importModule2moduleInfo, typeId2ClassMap ); end
return obj
end
function RootNode:__init(pos, typeList, children, moduleTypeInfo, provideNode, luneHelperInfo, importModule2moduleInfo, typeId2ClassMap) 
  Node.__init( self, _moduleObj.nodeKindRoot, pos, typeList)
  
  -- none
  
  self.children = children
  self.moduleTypeInfo = moduleTypeInfo
  self.provideNode = provideNode
  self.luneHelperInfo = luneHelperInfo
  self.importModule2moduleInfo = importModule2moduleInfo
  self.typeId2ClassMap = typeId2ClassMap
  -- none
  
end
function RootNode.setmeta( obj )
  setmetatable( obj, { __index = RootNode  } )
end
function RootNode:get_children()       
  return self.children         
end
function RootNode:get_moduleTypeInfo()       
  return self.moduleTypeInfo         
end
function RootNode:get_provideNode()       
  return self.provideNode         
end
function RootNode:get_luneHelperInfo()       
  return self.luneHelperInfo         
end
function RootNode:get_importModule2moduleInfo()       
  return self.importModule2moduleInfo         
end
function RootNode:get_typeId2ClassMap()       
  return self.typeId2ClassMap         
end
do
  end


function RootNode:set_provide( node )
  self.provideNode = node
end

-- none

function Filter:processRefType( node, ... )
end

-- none

-- none

local nodeKindRefType = regKind( [[RefType]] )

_moduleObj.nodeKindRefType = nodeKindRefType

local RefTypeNode = {}
setmetatable( RefTypeNode, { __index = Node } )
_moduleObj.RefTypeNode = RefTypeNode
function RefTypeNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processRefType( self, table.unpack( argList ) )
end
function RefTypeNode:canBeRight(  )
  return false
end
function RefTypeNode:canBeLeft(  )
  return false
end
function RefTypeNode.new( pos, typeList, name, refFlag, mutFlag, array )
  local obj = {}
  RefTypeNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, name, refFlag, mutFlag, array ); end
return obj
end
function RefTypeNode:__init(pos, typeList, name, refFlag, mutFlag, array) 
  Node.__init( self, _moduleObj.nodeKindRefType, pos, typeList)
  
  -- none
  
  self.name = name
  self.refFlag = refFlag
  self.mutFlag = mutFlag
  self.array = array
  -- none
  
end
function RefTypeNode.setmeta( obj )
  setmetatable( obj, { __index = RefTypeNode  } )
end
function RefTypeNode:get_name()       
  return self.name         
end
function RefTypeNode:get_refFlag()       
  return self.refFlag         
end
function RefTypeNode:get_mutFlag()       
  return self.mutFlag         
end
function RefTypeNode:get_array()       
  return self.array         
end
do
  end


local BlockKind = {}
_moduleObj.BlockKind = BlockKind
BlockKind._val2NameMap = {}
function BlockKind:_getTxt( val )
  local name = self._val2NameMap[ val ]
  if name then
    return string.format( "BlockKind.%s", name )
  end
  return string.format( "illegal val -- %s", val )
end 
function BlockKind:_from( val )
  if self._val2NameMap[ val ] then
    return val
  end
  return nil
end 
    
BlockKind.If = 0
BlockKind._val2NameMap[0] = 'If'
BlockKind.Elseif = 1
BlockKind._val2NameMap[1] = 'Elseif'
BlockKind.Else = 2
BlockKind._val2NameMap[2] = 'Else'
BlockKind.While = 3
BlockKind._val2NameMap[3] = 'While'
BlockKind.Switch = 4
BlockKind._val2NameMap[4] = 'Switch'
BlockKind.Repeat = 5
BlockKind._val2NameMap[5] = 'Repeat'
BlockKind.For = 6
BlockKind._val2NameMap[6] = 'For'
BlockKind.Apply = 7
BlockKind._val2NameMap[7] = 'Apply'
BlockKind.Foreach = 8
BlockKind._val2NameMap[8] = 'Foreach'
BlockKind.Macro = 13
BlockKind._val2NameMap[13] = 'Macro'
BlockKind.Func = 10
BlockKind._val2NameMap[10] = 'Func'
BlockKind.Default = 11
BlockKind._val2NameMap[11] = 'Default'
BlockKind.Block = 12
BlockKind._val2NameMap[12] = 'Block'
BlockKind.Macro = 13
BlockKind._val2NameMap[13] = 'Macro'
BlockKind.LetUnwrap = 14
BlockKind._val2NameMap[14] = 'LetUnwrap'
BlockKind.IfUnwrap = 15
BlockKind._val2NameMap[15] = 'IfUnwrap'

-- none

function Filter:processBlock( node, ... )
end

-- none

-- none

local nodeKindBlock = regKind( [[Block]] )

_moduleObj.nodeKindBlock = nodeKindBlock

local BlockNode = {}
setmetatable( BlockNode, { __index = Node } )
_moduleObj.BlockNode = BlockNode
function BlockNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processBlock( self, table.unpack( argList ) )
end
function BlockNode:canBeRight(  )
  return false
end
function BlockNode:canBeLeft(  )
  return false
end
function BlockNode.new( pos, typeList, blockKind, stmtList )
  local obj = {}
  BlockNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, blockKind, stmtList ); end
return obj
end
function BlockNode:__init(pos, typeList, blockKind, stmtList) 
  Node.__init( self, _moduleObj.nodeKindBlock, pos, typeList)
  
  -- none
  
  self.blockKind = blockKind
  self.stmtList = stmtList
  -- none
  
end
function BlockNode.setmeta( obj )
  setmetatable( obj, { __index = BlockNode  } )
end
function BlockNode:get_blockKind()       
  return self.blockKind         
end
function BlockNode:get_stmtList()       
  return self.stmtList         
end
do
  end


local IfStmtInfo = {}
_moduleObj.IfStmtInfo = IfStmtInfo
function IfStmtInfo.setmeta( obj )
  setmetatable( obj, { __index = IfStmtInfo  } )
end
function IfStmtInfo.new( kind, exp, block )
  local obj = {}
  IfStmtInfo.setmeta( obj )
  if obj.__init then
    obj:__init( kind, exp, block )
  end        
  return obj 
end         
function IfStmtInfo:__init( kind, exp, block ) 

self.kind = kind
  self.exp = exp
  self.block = block
  end
function IfStmtInfo:get_kind()       
  return self.kind         
end
function IfStmtInfo:get_exp()       
  return self.exp         
end
function IfStmtInfo:get_block()       
  return self.block         
end
do
  end

-- none

function Filter:processIf( node, ... )
end

-- none

-- none

local nodeKindIf = regKind( [[If]] )

_moduleObj.nodeKindIf = nodeKindIf

local IfNode = {}
setmetatable( IfNode, { __index = Node } )
_moduleObj.IfNode = IfNode
function IfNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processIf( self, table.unpack( argList ) )
end
function IfNode:canBeRight(  )
  return false
end
function IfNode:canBeLeft(  )
  return false
end
function IfNode.new( pos, typeList, stmtList )
  local obj = {}
  IfNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, stmtList ); end
return obj
end
function IfNode:__init(pos, typeList, stmtList) 
  Node.__init( self, _moduleObj.nodeKindIf, pos, typeList)
  
  -- none
  
  self.stmtList = stmtList
  -- none
  
end
function IfNode.setmeta( obj )
  setmetatable( obj, { __index = IfNode  } )
end
function IfNode:get_stmtList()       
  return self.stmtList         
end
do
  end


-- none

function Filter:processExpList( node, ... )
end

-- none

-- none

local nodeKindExpList = regKind( [[ExpList]] )

_moduleObj.nodeKindExpList = nodeKindExpList

local ExpListNode = {}
setmetatable( ExpListNode, { __index = Node } )
_moduleObj.ExpListNode = ExpListNode
function ExpListNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processExpList( self, table.unpack( argList ) )
end
function ExpListNode.new( pos, typeList, expList )
  local obj = {}
  ExpListNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, expList ); end
return obj
end
function ExpListNode:__init(pos, typeList, expList) 
  Node.__init( self, _moduleObj.nodeKindExpList, pos, typeList)
  
  -- none
  
  self.expList = expList
  -- none
  
end
function ExpListNode.setmeta( obj )
  setmetatable( obj, { __index = ExpListNode  } )
end
function ExpListNode:get_expList()       
  return self.expList         
end
do
  end


function ExpListNode:canBeLeft(  )
  for __index, expNode in pairs( self:get_expList() ) do
    if not expNode:canBeLeft(  ) then
      return false
    end
  end
  return true
end

function ExpListNode:canBeRight(  )
  for __index, expNode in pairs( self:get_expList() ) do
    if not expNode:canBeRight(  ) then
      return false
    end
  end
  return true
end

local CaseInfo = {}
_moduleObj.CaseInfo = CaseInfo
function CaseInfo.setmeta( obj )
  setmetatable( obj, { __index = CaseInfo  } )
end
function CaseInfo.new( expList, block )
  local obj = {}
  CaseInfo.setmeta( obj )
  if obj.__init then
    obj:__init( expList, block )
  end        
  return obj 
end         
function CaseInfo:__init( expList, block ) 

self.expList = expList
  self.block = block
  end
function CaseInfo:get_expList()       
  return self.expList         
end
function CaseInfo:get_block()       
  return self.block         
end
do
  end

-- none

function Filter:processSwitch( node, ... )
end

-- none

-- none

local nodeKindSwitch = regKind( [[Switch]] )

_moduleObj.nodeKindSwitch = nodeKindSwitch

local SwitchNode = {}
setmetatable( SwitchNode, { __index = Node } )
_moduleObj.SwitchNode = SwitchNode
function SwitchNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processSwitch( self, table.unpack( argList ) )
end
function SwitchNode:canBeRight(  )
  return false
end
function SwitchNode:canBeLeft(  )
  return false
end
function SwitchNode.new( pos, typeList, exp, caseList, default )
  local obj = {}
  SwitchNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, exp, caseList, default ); end
return obj
end
function SwitchNode:__init(pos, typeList, exp, caseList, default) 
  Node.__init( self, _moduleObj.nodeKindSwitch, pos, typeList)
  
  -- none
  
  self.exp = exp
  self.caseList = caseList
  self.default = default
  -- none
  
end
function SwitchNode.setmeta( obj )
  setmetatable( obj, { __index = SwitchNode  } )
end
function SwitchNode:get_exp()       
  return self.exp         
end
function SwitchNode:get_caseList()       
  return self.caseList         
end
function SwitchNode:get_default()       
  return self.default         
end
do
  end


-- none

function Filter:processWhile( node, ... )
end

-- none

-- none

local nodeKindWhile = regKind( [[While]] )

_moduleObj.nodeKindWhile = nodeKindWhile

local WhileNode = {}
setmetatable( WhileNode, { __index = Node } )
_moduleObj.WhileNode = WhileNode
function WhileNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processWhile( self, table.unpack( argList ) )
end
function WhileNode:canBeRight(  )
  return false
end
function WhileNode:canBeLeft(  )
  return false
end
function WhileNode.new( pos, typeList, exp, block )
  local obj = {}
  WhileNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, exp, block ); end
return obj
end
function WhileNode:__init(pos, typeList, exp, block) 
  Node.__init( self, _moduleObj.nodeKindWhile, pos, typeList)
  
  -- none
  
  self.exp = exp
  self.block = block
  -- none
  
end
function WhileNode.setmeta( obj )
  setmetatable( obj, { __index = WhileNode  } )
end
function WhileNode:get_exp()       
  return self.exp         
end
function WhileNode:get_block()       
  return self.block         
end
do
  end


-- none

function Filter:processRepeat( node, ... )
end

-- none

-- none

local nodeKindRepeat = regKind( [[Repeat]] )

_moduleObj.nodeKindRepeat = nodeKindRepeat

local RepeatNode = {}
setmetatable( RepeatNode, { __index = Node } )
_moduleObj.RepeatNode = RepeatNode
function RepeatNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processRepeat( self, table.unpack( argList ) )
end
function RepeatNode:canBeRight(  )
  return false
end
function RepeatNode:canBeLeft(  )
  return false
end
function RepeatNode.new( pos, typeList, block, exp )
  local obj = {}
  RepeatNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, block, exp ); end
return obj
end
function RepeatNode:__init(pos, typeList, block, exp) 
  Node.__init( self, _moduleObj.nodeKindRepeat, pos, typeList)
  
  -- none
  
  self.block = block
  self.exp = exp
  -- none
  
end
function RepeatNode.setmeta( obj )
  setmetatable( obj, { __index = RepeatNode  } )
end
function RepeatNode:get_block()       
  return self.block         
end
function RepeatNode:get_exp()       
  return self.exp         
end
do
  end


-- none

function Filter:processFor( node, ... )
end

-- none

-- none

local nodeKindFor = regKind( [[For]] )

_moduleObj.nodeKindFor = nodeKindFor

local ForNode = {}
setmetatable( ForNode, { __index = Node } )
_moduleObj.ForNode = ForNode
function ForNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processFor( self, table.unpack( argList ) )
end
function ForNode:canBeRight(  )
  return false
end
function ForNode:canBeLeft(  )
  return false
end
function ForNode.new( pos, typeList, block, val, init, to, delta )
  local obj = {}
  ForNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, block, val, init, to, delta ); end
return obj
end
function ForNode:__init(pos, typeList, block, val, init, to, delta) 
  Node.__init( self, _moduleObj.nodeKindFor, pos, typeList)
  
  -- none
  
  self.block = block
  self.val = val
  self.init = init
  self.to = to
  self.delta = delta
  -- none
  
end
function ForNode.setmeta( obj )
  setmetatable( obj, { __index = ForNode  } )
end
function ForNode:get_block()       
  return self.block         
end
function ForNode:get_val()       
  return self.val         
end
function ForNode:get_init()       
  return self.init         
end
function ForNode:get_to()       
  return self.to         
end
function ForNode:get_delta()       
  return self.delta         
end
do
  end


-- none

function Filter:processApply( node, ... )
end

-- none

-- none

local nodeKindApply = regKind( [[Apply]] )

_moduleObj.nodeKindApply = nodeKindApply

local ApplyNode = {}
setmetatable( ApplyNode, { __index = Node } )
_moduleObj.ApplyNode = ApplyNode
function ApplyNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processApply( self, table.unpack( argList ) )
end
function ApplyNode:canBeRight(  )
  return false
end
function ApplyNode:canBeLeft(  )
  return false
end
function ApplyNode.new( pos, typeList, varList, exp, block )
  local obj = {}
  ApplyNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, varList, exp, block ); end
return obj
end
function ApplyNode:__init(pos, typeList, varList, exp, block) 
  Node.__init( self, _moduleObj.nodeKindApply, pos, typeList)
  
  -- none
  
  self.varList = varList
  self.exp = exp
  self.block = block
  -- none
  
end
function ApplyNode.setmeta( obj )
  setmetatable( obj, { __index = ApplyNode  } )
end
function ApplyNode:get_varList()       
  return self.varList         
end
function ApplyNode:get_exp()       
  return self.exp         
end
function ApplyNode:get_block()       
  return self.block         
end
do
  end


-- none

function Filter:processForeach( node, ... )
end

-- none

-- none

local nodeKindForeach = regKind( [[Foreach]] )

_moduleObj.nodeKindForeach = nodeKindForeach

local ForeachNode = {}
setmetatable( ForeachNode, { __index = Node } )
_moduleObj.ForeachNode = ForeachNode
function ForeachNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processForeach( self, table.unpack( argList ) )
end
function ForeachNode:canBeRight(  )
  return false
end
function ForeachNode:canBeLeft(  )
  return false
end
function ForeachNode.new( pos, typeList, val, key, exp, block )
  local obj = {}
  ForeachNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, val, key, exp, block ); end
return obj
end
function ForeachNode:__init(pos, typeList, val, key, exp, block) 
  Node.__init( self, _moduleObj.nodeKindForeach, pos, typeList)
  
  -- none
  
  self.val = val
  self.key = key
  self.exp = exp
  self.block = block
  -- none
  
end
function ForeachNode.setmeta( obj )
  setmetatable( obj, { __index = ForeachNode  } )
end
function ForeachNode:get_val()       
  return self.val         
end
function ForeachNode:get_key()       
  return self.key         
end
function ForeachNode:get_exp()       
  return self.exp         
end
function ForeachNode:get_block()       
  return self.block         
end
do
  end


-- none

function Filter:processForsort( node, ... )
end

-- none

-- none

local nodeKindForsort = regKind( [[Forsort]] )

_moduleObj.nodeKindForsort = nodeKindForsort

local ForsortNode = {}
setmetatable( ForsortNode, { __index = Node } )
_moduleObj.ForsortNode = ForsortNode
function ForsortNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processForsort( self, table.unpack( argList ) )
end
function ForsortNode:canBeRight(  )
  return false
end
function ForsortNode:canBeLeft(  )
  return false
end
function ForsortNode.new( pos, typeList, val, key, exp, block, sort )
  local obj = {}
  ForsortNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, val, key, exp, block, sort ); end
return obj
end
function ForsortNode:__init(pos, typeList, val, key, exp, block, sort) 
  Node.__init( self, _moduleObj.nodeKindForsort, pos, typeList)
  
  -- none
  
  self.val = val
  self.key = key
  self.exp = exp
  self.block = block
  self.sort = sort
  -- none
  
end
function ForsortNode.setmeta( obj )
  setmetatable( obj, { __index = ForsortNode  } )
end
function ForsortNode:get_val()       
  return self.val         
end
function ForsortNode:get_key()       
  return self.key         
end
function ForsortNode:get_exp()       
  return self.exp         
end
function ForsortNode:get_block()       
  return self.block         
end
function ForsortNode:get_sort()       
  return self.sort         
end
do
  end


-- none

function Filter:processReturn( node, ... )
end

-- none

-- none

local nodeKindReturn = regKind( [[Return]] )

_moduleObj.nodeKindReturn = nodeKindReturn

local ReturnNode = {}
setmetatable( ReturnNode, { __index = Node } )
_moduleObj.ReturnNode = ReturnNode
function ReturnNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processReturn( self, table.unpack( argList ) )
end
function ReturnNode:canBeRight(  )
  return false
end
function ReturnNode:canBeLeft(  )
  return false
end
function ReturnNode.new( pos, typeList, expList )
  local obj = {}
  ReturnNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, expList ); end
return obj
end
function ReturnNode:__init(pos, typeList, expList) 
  Node.__init( self, _moduleObj.nodeKindReturn, pos, typeList)
  
  -- none
  
  self.expList = expList
  -- none
  
end
function ReturnNode.setmeta( obj )
  setmetatable( obj, { __index = ReturnNode  } )
end
function ReturnNode:get_expList()       
  return self.expList         
end
do
  end


-- none

function Filter:processBreak( node, ... )
end

-- none

-- none

local nodeKindBreak = regKind( [[Break]] )

_moduleObj.nodeKindBreak = nodeKindBreak

local BreakNode = {}
setmetatable( BreakNode, { __index = Node } )
_moduleObj.BreakNode = BreakNode
function BreakNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processBreak( self, table.unpack( argList ) )
end
function BreakNode:canBeRight(  )
  return false
end
function BreakNode:canBeLeft(  )
  return false
end
function BreakNode.new( pos, typeList )
  local obj = {}
  BreakNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList ); end
return obj
end
function BreakNode:__init(pos, typeList) 
  Node.__init( self, _moduleObj.nodeKindBreak, pos, typeList)
  
  -- none
  
  -- none
  
end
function BreakNode.setmeta( obj )
  setmetatable( obj, { __index = BreakNode  } )
end
do
  end


-- none

function Filter:processProvide( node, ... )
end

-- none

-- none

local nodeKindProvide = regKind( [[Provide]] )

_moduleObj.nodeKindProvide = nodeKindProvide

local ProvideNode = {}
setmetatable( ProvideNode, { __index = Node } )
_moduleObj.ProvideNode = ProvideNode
function ProvideNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processProvide( self, table.unpack( argList ) )
end
function ProvideNode:canBeRight(  )
  return false
end
function ProvideNode:canBeLeft(  )
  return false
end
function ProvideNode.new( pos, typeList, val )
  local obj = {}
  ProvideNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, val ); end
return obj
end
function ProvideNode:__init(pos, typeList, val) 
  Node.__init( self, _moduleObj.nodeKindProvide, pos, typeList)
  
  -- none
  
  self.val = val
  -- none
  
end
function ProvideNode.setmeta( obj )
  setmetatable( obj, { __index = ProvideNode  } )
end
function ProvideNode:get_val()       
  return self.val         
end
do
  end


-- none

function Filter:processExpNew( node, ... )
end

-- none

-- none

local nodeKindExpNew = regKind( [[ExpNew]] )

_moduleObj.nodeKindExpNew = nodeKindExpNew

local ExpNewNode = {}
setmetatable( ExpNewNode, { __index = Node } )
_moduleObj.ExpNewNode = ExpNewNode
function ExpNewNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processExpNew( self, table.unpack( argList ) )
end
function ExpNewNode:canBeRight(  )
  return true
end
function ExpNewNode:canBeLeft(  )
  return false
end
function ExpNewNode.new( pos, typeList, symbol, argList )
  local obj = {}
  ExpNewNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, symbol, argList ); end
return obj
end
function ExpNewNode:__init(pos, typeList, symbol, argList) 
  Node.__init( self, _moduleObj.nodeKindExpNew, pos, typeList)
  
  -- none
  
  self.symbol = symbol
  self.argList = argList
  -- none
  
end
function ExpNewNode.setmeta( obj )
  setmetatable( obj, { __index = ExpNewNode  } )
end
function ExpNewNode:get_symbol()       
  return self.symbol         
end
function ExpNewNode:get_argList()       
  return self.argList         
end
do
  end


-- none

function Filter:processExpUnwrap( node, ... )
end

-- none

-- none

local nodeKindExpUnwrap = regKind( [[ExpUnwrap]] )

_moduleObj.nodeKindExpUnwrap = nodeKindExpUnwrap

local ExpUnwrapNode = {}
setmetatable( ExpUnwrapNode, { __index = Node } )
_moduleObj.ExpUnwrapNode = ExpUnwrapNode
function ExpUnwrapNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processExpUnwrap( self, table.unpack( argList ) )
end
function ExpUnwrapNode:canBeRight(  )
  return true
end
function ExpUnwrapNode:canBeLeft(  )
  return false
end
function ExpUnwrapNode.new( pos, typeList, exp, default )
  local obj = {}
  ExpUnwrapNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, exp, default ); end
return obj
end
function ExpUnwrapNode:__init(pos, typeList, exp, default) 
  Node.__init( self, _moduleObj.nodeKindExpUnwrap, pos, typeList)
  
  -- none
  
  self.exp = exp
  self.default = default
  -- none
  
end
function ExpUnwrapNode.setmeta( obj )
  setmetatable( obj, { __index = ExpUnwrapNode  } )
end
function ExpUnwrapNode:get_exp()       
  return self.exp         
end
function ExpUnwrapNode:get_default()       
  return self.default         
end
do
  end


-- none

function Filter:processExpRef( node, ... )
end

-- none

-- none

local nodeKindExpRef = regKind( [[ExpRef]] )

_moduleObj.nodeKindExpRef = nodeKindExpRef

local ExpRefNode = {}
setmetatable( ExpRefNode, { __index = Node } )
_moduleObj.ExpRefNode = ExpRefNode
function ExpRefNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processExpRef( self, table.unpack( argList ) )
end
function ExpRefNode.new( pos, typeList, token, symbolInfo )
  local obj = {}
  ExpRefNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, token, symbolInfo ); end
return obj
end
function ExpRefNode:__init(pos, typeList, token, symbolInfo) 
  Node.__init( self, _moduleObj.nodeKindExpRef, pos, typeList)
  
  -- none
  
  self.token = token
  self.symbolInfo = symbolInfo
  -- none
  
end
function ExpRefNode.setmeta( obj )
  setmetatable( obj, { __index = ExpRefNode  } )
end
function ExpRefNode:get_token()       
  return self.token         
end
function ExpRefNode:get_symbolInfo()       
  return self.symbolInfo         
end
do
  end


function ExpRefNode:canBeLeft(  )
  return self:get_symbolInfo():get_canBeLeft()
end

function ExpRefNode:canBeRight(  )
  return self:get_symbolInfo():get_canBeRight()
end

-- none

function Filter:processExpOp2( node, ... )
end

-- none

-- none

local nodeKindExpOp2 = regKind( [[ExpOp2]] )

_moduleObj.nodeKindExpOp2 = nodeKindExpOp2

local ExpOp2Node = {}
setmetatable( ExpOp2Node, { __index = Node } )
_moduleObj.ExpOp2Node = ExpOp2Node
function ExpOp2Node:processFilter( filter, ... )
  local argList = {...}
  
  filter:processExpOp2( self, table.unpack( argList ) )
end
function ExpOp2Node:canBeRight(  )
  return true
end
function ExpOp2Node:canBeLeft(  )
  return false
end
function ExpOp2Node.new( pos, typeList, op, exp1, exp2 )
  local obj = {}
  ExpOp2Node.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, op, exp1, exp2 ); end
return obj
end
function ExpOp2Node:__init(pos, typeList, op, exp1, exp2) 
  Node.__init( self, _moduleObj.nodeKindExpOp2, pos, typeList)
  
  -- none
  
  self.op = op
  self.exp1 = exp1
  self.exp2 = exp2
  -- none
  
end
function ExpOp2Node.setmeta( obj )
  setmetatable( obj, { __index = ExpOp2Node  } )
end
function ExpOp2Node:get_op()       
  return self.op         
end
function ExpOp2Node:get_exp1()       
  return self.exp1         
end
function ExpOp2Node:get_exp2()       
  return self.exp2         
end
do
  end


-- none

function Filter:processUnwrapSet( node, ... )
end

-- none

-- none

local nodeKindUnwrapSet = regKind( [[UnwrapSet]] )

_moduleObj.nodeKindUnwrapSet = nodeKindUnwrapSet

local UnwrapSetNode = {}
setmetatable( UnwrapSetNode, { __index = Node } )
_moduleObj.UnwrapSetNode = UnwrapSetNode
function UnwrapSetNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processUnwrapSet( self, table.unpack( argList ) )
end
function UnwrapSetNode:canBeRight(  )
  return false
end
function UnwrapSetNode:canBeLeft(  )
  return false
end
function UnwrapSetNode.new( pos, typeList, dstExpList, srcExpList, unwrapBlock )
  local obj = {}
  UnwrapSetNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, dstExpList, srcExpList, unwrapBlock ); end
return obj
end
function UnwrapSetNode:__init(pos, typeList, dstExpList, srcExpList, unwrapBlock) 
  Node.__init( self, _moduleObj.nodeKindUnwrapSet, pos, typeList)
  
  -- none
  
  self.dstExpList = dstExpList
  self.srcExpList = srcExpList
  self.unwrapBlock = unwrapBlock
  -- none
  
end
function UnwrapSetNode.setmeta( obj )
  setmetatable( obj, { __index = UnwrapSetNode  } )
end
function UnwrapSetNode:get_dstExpList()       
  return self.dstExpList         
end
function UnwrapSetNode:get_srcExpList()       
  return self.srcExpList         
end
function UnwrapSetNode:get_unwrapBlock()       
  return self.unwrapBlock         
end
do
  end


-- none

function Filter:processIfUnwrap( node, ... )
end

-- none

-- none

local nodeKindIfUnwrap = regKind( [[IfUnwrap]] )

_moduleObj.nodeKindIfUnwrap = nodeKindIfUnwrap

local IfUnwrapNode = {}
setmetatable( IfUnwrapNode, { __index = Node } )
_moduleObj.IfUnwrapNode = IfUnwrapNode
function IfUnwrapNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processIfUnwrap( self, table.unpack( argList ) )
end
function IfUnwrapNode:canBeRight(  )
  return false
end
function IfUnwrapNode:canBeLeft(  )
  return false
end
function IfUnwrapNode.new( pos, typeList, varNameList, expNodeList, block, nilBlock )
  local obj = {}
  IfUnwrapNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, varNameList, expNodeList, block, nilBlock ); end
return obj
end
function IfUnwrapNode:__init(pos, typeList, varNameList, expNodeList, block, nilBlock) 
  Node.__init( self, _moduleObj.nodeKindIfUnwrap, pos, typeList)
  
  -- none
  
  self.varNameList = varNameList
  self.expNodeList = expNodeList
  self.block = block
  self.nilBlock = nilBlock
  -- none
  
end
function IfUnwrapNode.setmeta( obj )
  setmetatable( obj, { __index = IfUnwrapNode  } )
end
function IfUnwrapNode:get_varNameList()       
  return self.varNameList         
end
function IfUnwrapNode:get_expNodeList()       
  return self.expNodeList         
end
function IfUnwrapNode:get_block()       
  return self.block         
end
function IfUnwrapNode:get_nilBlock()       
  return self.nilBlock         
end
do
  end


-- none

function Filter:processExpCast( node, ... )
end

-- none

-- none

local nodeKindExpCast = regKind( [[ExpCast]] )

_moduleObj.nodeKindExpCast = nodeKindExpCast

local ExpCastNode = {}
setmetatable( ExpCastNode, { __index = Node } )
_moduleObj.ExpCastNode = ExpCastNode
function ExpCastNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processExpCast( self, table.unpack( argList ) )
end
function ExpCastNode:canBeRight(  )
  return true
end
function ExpCastNode:canBeLeft(  )
  return false
end
function ExpCastNode.new( pos, typeList, exp )
  local obj = {}
  ExpCastNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, exp ); end
return obj
end
function ExpCastNode:__init(pos, typeList, exp) 
  Node.__init( self, _moduleObj.nodeKindExpCast, pos, typeList)
  
  -- none
  
  self.exp = exp
  -- none
  
end
function ExpCastNode.setmeta( obj )
  setmetatable( obj, { __index = ExpCastNode  } )
end
function ExpCastNode:get_exp()       
  return self.exp         
end
do
  end


local MacroMode = {}
_moduleObj.MacroMode = MacroMode
MacroMode._val2NameMap = {}
function MacroMode:_getTxt( val )
  local name = self._val2NameMap[ val ]
  if name then
    return string.format( "MacroMode.%s", name )
  end
  return string.format( "illegal val -- %s", val )
end 
function MacroMode:_from( val )
  if self._val2NameMap[ val ] then
    return val
  end
  return nil
end 
    
MacroMode.None = 0
MacroMode._val2NameMap[0] = 'None'
MacroMode.Expand = 1
MacroMode._val2NameMap[1] = 'Expand'
MacroMode.Analyze = 2
MacroMode._val2NameMap[2] = 'Analyze'

-- none

function Filter:processExpOp1( node, ... )
end

-- none

-- none

local nodeKindExpOp1 = regKind( [[ExpOp1]] )

_moduleObj.nodeKindExpOp1 = nodeKindExpOp1

local ExpOp1Node = {}
setmetatable( ExpOp1Node, { __index = Node } )
_moduleObj.ExpOp1Node = ExpOp1Node
function ExpOp1Node:processFilter( filter, ... )
  local argList = {...}
  
  filter:processExpOp1( self, table.unpack( argList ) )
end
function ExpOp1Node:canBeRight(  )
  return true
end
function ExpOp1Node:canBeLeft(  )
  return false
end
function ExpOp1Node.new( pos, typeList, op, macroMode, exp )
  local obj = {}
  ExpOp1Node.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, op, macroMode, exp ); end
return obj
end
function ExpOp1Node:__init(pos, typeList, op, macroMode, exp) 
  Node.__init( self, _moduleObj.nodeKindExpOp1, pos, typeList)
  
  -- none
  
  self.op = op
  self.macroMode = macroMode
  self.exp = exp
  -- none
  
end
function ExpOp1Node.setmeta( obj )
  setmetatable( obj, { __index = ExpOp1Node  } )
end
function ExpOp1Node:get_op()       
  return self.op         
end
function ExpOp1Node:get_macroMode()       
  return self.macroMode         
end
function ExpOp1Node:get_exp()       
  return self.exp         
end
do
  end


-- none

function Filter:processExpRefItem( node, ... )
end

-- none

-- none

local nodeKindExpRefItem = regKind( [[ExpRefItem]] )

_moduleObj.nodeKindExpRefItem = nodeKindExpRefItem

local ExpRefItemNode = {}
setmetatable( ExpRefItemNode, { __index = Node } )
_moduleObj.ExpRefItemNode = ExpRefItemNode
function ExpRefItemNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processExpRefItem( self, table.unpack( argList ) )
end
function ExpRefItemNode:canBeRight(  )
  return true
end
function ExpRefItemNode.new( pos, typeList, val, nilAccess, symbol, index )
  local obj = {}
  ExpRefItemNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, val, nilAccess, symbol, index ); end
return obj
end
function ExpRefItemNode:__init(pos, typeList, val, nilAccess, symbol, index) 
  Node.__init( self, _moduleObj.nodeKindExpRefItem, pos, typeList)
  
  -- none
  
  self.val = val
  self.nilAccess = nilAccess
  self.symbol = symbol
  self.index = index
  -- none
  
end
function ExpRefItemNode.setmeta( obj )
  setmetatable( obj, { __index = ExpRefItemNode  } )
end
function ExpRefItemNode:get_val()       
  return self.val         
end
function ExpRefItemNode:get_nilAccess()       
  return self.nilAccess         
end
function ExpRefItemNode:get_symbol()       
  return self.symbol         
end
function ExpRefItemNode:get_index()       
  return self.index         
end
do
  end


function ExpRefItemNode:canBeLeft(  )
  if self.val:get_expType() == _moduleObj.builtinTypeStem then
    return false
  end
  return self:get_val():get_expType():get_mutable() and not self.nilAccess
end

-- none

function Filter:processExpCall( node, ... )
end

-- none

-- none

local nodeKindExpCall = regKind( [[ExpCall]] )

_moduleObj.nodeKindExpCall = nodeKindExpCall

local ExpCallNode = {}
setmetatable( ExpCallNode, { __index = Node } )
_moduleObj.ExpCallNode = ExpCallNode
function ExpCallNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processExpCall( self, table.unpack( argList ) )
end
function ExpCallNode:canBeRight(  )
  return true
end
function ExpCallNode:canBeLeft(  )
  return false
end
function ExpCallNode.new( pos, typeList, func, nilAccess, argList )
  local obj = {}
  ExpCallNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, func, nilAccess, argList ); end
return obj
end
function ExpCallNode:__init(pos, typeList, func, nilAccess, argList) 
  Node.__init( self, _moduleObj.nodeKindExpCall, pos, typeList)
  
  -- none
  
  self.func = func
  self.nilAccess = nilAccess
  self.argList = argList
  -- none
  
end
function ExpCallNode.setmeta( obj )
  setmetatable( obj, { __index = ExpCallNode  } )
end
function ExpCallNode:get_func()       
  return self.func         
end
function ExpCallNode:get_nilAccess()       
  return self.nilAccess         
end
function ExpCallNode:get_argList()       
  return self.argList         
end
do
  end


-- none

function Filter:processExpDDD( node, ... )
end

-- none

-- none

local nodeKindExpDDD = regKind( [[ExpDDD]] )

_moduleObj.nodeKindExpDDD = nodeKindExpDDD

local ExpDDDNode = {}
setmetatable( ExpDDDNode, { __index = Node } )
_moduleObj.ExpDDDNode = ExpDDDNode
function ExpDDDNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processExpDDD( self, table.unpack( argList ) )
end
function ExpDDDNode:canBeRight(  )
  return true
end
function ExpDDDNode:canBeLeft(  )
  return false
end
function ExpDDDNode.new( pos, typeList, token )
  local obj = {}
  ExpDDDNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, token ); end
return obj
end
function ExpDDDNode:__init(pos, typeList, token) 
  Node.__init( self, _moduleObj.nodeKindExpDDD, pos, typeList)
  
  -- none
  
  self.token = token
  -- none
  
end
function ExpDDDNode.setmeta( obj )
  setmetatable( obj, { __index = ExpDDDNode  } )
end
function ExpDDDNode:get_token()       
  return self.token         
end
do
  end


-- none

function Filter:processExpParen( node, ... )
end

-- none

-- none

local nodeKindExpParen = regKind( [[ExpParen]] )

_moduleObj.nodeKindExpParen = nodeKindExpParen

local ExpParenNode = {}
setmetatable( ExpParenNode, { __index = Node } )
_moduleObj.ExpParenNode = ExpParenNode
function ExpParenNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processExpParen( self, table.unpack( argList ) )
end
function ExpParenNode:canBeRight(  )
  return true
end
function ExpParenNode:canBeLeft(  )
  return false
end
function ExpParenNode.new( pos, typeList, exp )
  local obj = {}
  ExpParenNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, exp ); end
return obj
end
function ExpParenNode:__init(pos, typeList, exp) 
  Node.__init( self, _moduleObj.nodeKindExpParen, pos, typeList)
  
  -- none
  
  self.exp = exp
  -- none
  
end
function ExpParenNode.setmeta( obj )
  setmetatable( obj, { __index = ExpParenNode  } )
end
function ExpParenNode:get_exp()       
  return self.exp         
end
do
  end


-- none

function Filter:processExpMacroExp( node, ... )
end

-- none

-- none

local nodeKindExpMacroExp = regKind( [[ExpMacroExp]] )

_moduleObj.nodeKindExpMacroExp = nodeKindExpMacroExp

local ExpMacroExpNode = {}
setmetatable( ExpMacroExpNode, { __index = Node } )
_moduleObj.ExpMacroExpNode = ExpMacroExpNode
function ExpMacroExpNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processExpMacroExp( self, table.unpack( argList ) )
end
function ExpMacroExpNode:canBeRight(  )
  return false
end
function ExpMacroExpNode:canBeLeft(  )
  return false
end
function ExpMacroExpNode.new( pos, typeList, stmtList )
  local obj = {}
  ExpMacroExpNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, stmtList ); end
return obj
end
function ExpMacroExpNode:__init(pos, typeList, stmtList) 
  Node.__init( self, _moduleObj.nodeKindExpMacroExp, pos, typeList)
  
  -- none
  
  self.stmtList = stmtList
  -- none
  
end
function ExpMacroExpNode.setmeta( obj )
  setmetatable( obj, { __index = ExpMacroExpNode  } )
end
function ExpMacroExpNode:get_stmtList()       
  return self.stmtList         
end
do
  end


-- none

function Filter:processExpMacroStat( node, ... )
end

-- none

-- none

local nodeKindExpMacroStat = regKind( [[ExpMacroStat]] )

_moduleObj.nodeKindExpMacroStat = nodeKindExpMacroStat

local ExpMacroStatNode = {}
setmetatable( ExpMacroStatNode, { __index = Node } )
_moduleObj.ExpMacroStatNode = ExpMacroStatNode
function ExpMacroStatNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processExpMacroStat( self, table.unpack( argList ) )
end
function ExpMacroStatNode:canBeRight(  )
  return true
end
function ExpMacroStatNode:canBeLeft(  )
  return false
end
function ExpMacroStatNode.new( pos, typeList, expStrList )
  local obj = {}
  ExpMacroStatNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, expStrList ); end
return obj
end
function ExpMacroStatNode:__init(pos, typeList, expStrList) 
  Node.__init( self, _moduleObj.nodeKindExpMacroStat, pos, typeList)
  
  -- none
  
  self.expStrList = expStrList
  -- none
  
end
function ExpMacroStatNode.setmeta( obj )
  setmetatable( obj, { __index = ExpMacroStatNode  } )
end
function ExpMacroStatNode:get_expStrList()       
  return self.expStrList         
end
do
  end


-- none

function Filter:processStmtExp( node, ... )
end

-- none

-- none

local nodeKindStmtExp = regKind( [[StmtExp]] )

_moduleObj.nodeKindStmtExp = nodeKindStmtExp

local StmtExpNode = {}
setmetatable( StmtExpNode, { __index = Node } )
_moduleObj.StmtExpNode = StmtExpNode
function StmtExpNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processStmtExp( self, table.unpack( argList ) )
end
function StmtExpNode:canBeRight(  )
  return true
end
function StmtExpNode:canBeLeft(  )
  return false
end
function StmtExpNode.new( pos, typeList, exp )
  local obj = {}
  StmtExpNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, exp ); end
return obj
end
function StmtExpNode:__init(pos, typeList, exp) 
  Node.__init( self, _moduleObj.nodeKindStmtExp, pos, typeList)
  
  -- none
  
  self.exp = exp
  -- none
  
end
function StmtExpNode.setmeta( obj )
  setmetatable( obj, { __index = StmtExpNode  } )
end
function StmtExpNode:get_exp()       
  return self.exp         
end
do
  end


-- none

function Filter:processExpOmitEnum( node, ... )
end

-- none

-- none

local nodeKindExpOmitEnum = regKind( [[ExpOmitEnum]] )

_moduleObj.nodeKindExpOmitEnum = nodeKindExpOmitEnum

local ExpOmitEnumNode = {}
setmetatable( ExpOmitEnumNode, { __index = Node } )
_moduleObj.ExpOmitEnumNode = ExpOmitEnumNode
function ExpOmitEnumNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processExpOmitEnum( self, table.unpack( argList ) )
end
function ExpOmitEnumNode:canBeRight(  )
  return true
end
function ExpOmitEnumNode:canBeLeft(  )
  return true
end
function ExpOmitEnumNode.new( pos, typeList, valToken, enumTypeInfo )
  local obj = {}
  ExpOmitEnumNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, valToken, enumTypeInfo ); end
return obj
end
function ExpOmitEnumNode:__init(pos, typeList, valToken, enumTypeInfo) 
  Node.__init( self, _moduleObj.nodeKindExpOmitEnum, pos, typeList)
  
  -- none
  
  self.valToken = valToken
  self.enumTypeInfo = enumTypeInfo
  -- none
  
end
function ExpOmitEnumNode.setmeta( obj )
  setmetatable( obj, { __index = ExpOmitEnumNode  } )
end
function ExpOmitEnumNode:get_valToken()       
  return self.valToken         
end
function ExpOmitEnumNode:get_enumTypeInfo()       
  return self.enumTypeInfo         
end
do
  end


-- none

function Filter:processRefField( node, ... )
end

-- none

-- none

local nodeKindRefField = regKind( [[RefField]] )

_moduleObj.nodeKindRefField = nodeKindRefField

local RefFieldNode = {}
setmetatable( RefFieldNode, { __index = Node } )
_moduleObj.RefFieldNode = RefFieldNode
function RefFieldNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processRefField( self, table.unpack( argList ) )
end
function RefFieldNode:canBeRight(  )
  return true
end
function RefFieldNode.new( pos, typeList, field, symbolInfo, nilAccess, prefix )
  local obj = {}
  RefFieldNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, field, symbolInfo, nilAccess, prefix ); end
return obj
end
function RefFieldNode:__init(pos, typeList, field, symbolInfo, nilAccess, prefix) 
  Node.__init( self, _moduleObj.nodeKindRefField, pos, typeList)
  
  -- none
  
  self.field = field
  self.symbolInfo = symbolInfo
  self.nilAccess = nilAccess
  self.prefix = prefix
  -- none
  
end
function RefFieldNode.setmeta( obj )
  setmetatable( obj, { __index = RefFieldNode  } )
end
function RefFieldNode:get_field()       
  return self.field         
end
function RefFieldNode:get_symbolInfo()       
  return self.symbolInfo         
end
function RefFieldNode:get_nilAccess()       
  return self.nilAccess         
end
function RefFieldNode:get_prefix()       
  return self.prefix         
end
do
  end


function RefFieldNode:canBeLeft(  )
  do
    local _exp = self:get_symbolInfo()
    if _exp ~= nil then
    
        return _exp:get_canBeLeft()
      end
  end
  
  return false
end

-- none

function Filter:processGetField( node, ... )
end

-- none

-- none

local nodeKindGetField = regKind( [[GetField]] )

_moduleObj.nodeKindGetField = nodeKindGetField

local GetFieldNode = {}
setmetatable( GetFieldNode, { __index = Node } )
_moduleObj.GetFieldNode = GetFieldNode
function GetFieldNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processGetField( self, table.unpack( argList ) )
end
function GetFieldNode:canBeRight(  )
  return true
end
function GetFieldNode.new( pos, typeList, field, symbolInfo, nilAccess, prefix, getterTypeInfo )
  local obj = {}
  GetFieldNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, field, symbolInfo, nilAccess, prefix, getterTypeInfo ); end
return obj
end
function GetFieldNode:__init(pos, typeList, field, symbolInfo, nilAccess, prefix, getterTypeInfo) 
  Node.__init( self, _moduleObj.nodeKindGetField, pos, typeList)
  
  -- none
  
  self.field = field
  self.symbolInfo = symbolInfo
  self.nilAccess = nilAccess
  self.prefix = prefix
  self.getterTypeInfo = getterTypeInfo
  -- none
  
end
function GetFieldNode.setmeta( obj )
  setmetatable( obj, { __index = GetFieldNode  } )
end
function GetFieldNode:get_field()       
  return self.field         
end
function GetFieldNode:get_symbolInfo()       
  return self.symbolInfo         
end
function GetFieldNode:get_nilAccess()       
  return self.nilAccess         
end
function GetFieldNode:get_prefix()       
  return self.prefix         
end
function GetFieldNode:get_getterTypeInfo()       
  return self.getterTypeInfo         
end
do
  end


function GetFieldNode:canBeLeft(  )
  do
    local _exp = self:get_symbolInfo()
    if _exp ~= nil then
    
        return _exp:get_canBeLeft()
      end
  end
  
  return false
end

local VarInfo = {}
_moduleObj.VarInfo = VarInfo
function VarInfo.setmeta( obj )
  setmetatable( obj, { __index = VarInfo  } )
end
function VarInfo.new( name, refType, actualType )
  local obj = {}
  VarInfo.setmeta( obj )
  if obj.__init then
    obj:__init( name, refType, actualType )
  end        
  return obj 
end         
function VarInfo:__init( name, refType, actualType ) 

self.name = name
  self.refType = refType
  self.actualType = actualType
  end
function VarInfo:get_name()       
  return self.name         
end
function VarInfo:get_refType()       
  return self.refType         
end
function VarInfo:get_actualType()       
  return self.actualType         
end
do
  end

local DeclVarMode = {}
_moduleObj.DeclVarMode = DeclVarMode
DeclVarMode._val2NameMap = {}
function DeclVarMode:_getTxt( val )
  local name = self._val2NameMap[ val ]
  if name then
    return string.format( "DeclVarMode.%s", name )
  end
  return string.format( "illegal val -- %s", val )
end 
function DeclVarMode:_from( val )
  if self._val2NameMap[ val ] then
    return val
  end
  return nil
end 
    
DeclVarMode.Let = 0
DeclVarMode._val2NameMap[0] = 'Let'
DeclVarMode.Sync = 1
DeclVarMode._val2NameMap[1] = 'Sync'
DeclVarMode.Unwrap = 2
DeclVarMode._val2NameMap[2] = 'Unwrap'

-- none

function Filter:processDeclVar( node, ... )
end

-- none

-- none

local nodeKindDeclVar = regKind( [[DeclVar]] )

_moduleObj.nodeKindDeclVar = nodeKindDeclVar

local DeclVarNode = {}
setmetatable( DeclVarNode, { __index = Node } )
_moduleObj.DeclVarNode = DeclVarNode
function DeclVarNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processDeclVar( self, table.unpack( argList ) )
end
function DeclVarNode:canBeRight(  )
  return false
end
function DeclVarNode:canBeLeft(  )
  return false
end
function DeclVarNode.new( pos, typeList, mode, accessMode, staticFlag, varList, expList, symbolInfoList, typeInfoList, unwrapFlag, unwrapBlock, thenBlock, syncVarList, syncBlock )
  local obj = {}
  DeclVarNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, mode, accessMode, staticFlag, varList, expList, symbolInfoList, typeInfoList, unwrapFlag, unwrapBlock, thenBlock, syncVarList, syncBlock ); end
return obj
end
function DeclVarNode:__init(pos, typeList, mode, accessMode, staticFlag, varList, expList, symbolInfoList, typeInfoList, unwrapFlag, unwrapBlock, thenBlock, syncVarList, syncBlock) 
  Node.__init( self, _moduleObj.nodeKindDeclVar, pos, typeList)
  
  -- none
  
  self.mode = mode
  self.accessMode = accessMode
  self.staticFlag = staticFlag
  self.varList = varList
  self.expList = expList
  self.symbolInfoList = symbolInfoList
  self.typeInfoList = typeInfoList
  self.unwrapFlag = unwrapFlag
  self.unwrapBlock = unwrapBlock
  self.thenBlock = thenBlock
  self.syncVarList = syncVarList
  self.syncBlock = syncBlock
  -- none
  
end
function DeclVarNode.setmeta( obj )
  setmetatable( obj, { __index = DeclVarNode  } )
end
function DeclVarNode:get_mode()       
  return self.mode         
end
function DeclVarNode:get_accessMode()       
  return self.accessMode         
end
function DeclVarNode:get_staticFlag()       
  return self.staticFlag         
end
function DeclVarNode:get_varList()       
  return self.varList         
end
function DeclVarNode:get_expList()       
  return self.expList         
end
function DeclVarNode:get_symbolInfoList()       
  return self.symbolInfoList         
end
function DeclVarNode:get_typeInfoList()       
  return self.typeInfoList         
end
function DeclVarNode:get_unwrapFlag()       
  return self.unwrapFlag         
end
function DeclVarNode:get_unwrapBlock()       
  return self.unwrapBlock         
end
function DeclVarNode:get_thenBlock()       
  return self.thenBlock         
end
function DeclVarNode:get_syncVarList()       
  return self.syncVarList         
end
function DeclVarNode:get_syncBlock()       
  return self.syncBlock         
end
do
  end


local DeclFuncInfo = {}
_moduleObj.DeclFuncInfo = DeclFuncInfo
function DeclFuncInfo.setmeta( obj )
  setmetatable( obj, { __index = DeclFuncInfo  } )
end
function DeclFuncInfo.new( className, name, argList, staticFlag, accessMode, body, retTypeInfoList )
  local obj = {}
  DeclFuncInfo.setmeta( obj )
  if obj.__init then
    obj:__init( className, name, argList, staticFlag, accessMode, body, retTypeInfoList )
  end        
  return obj 
end         
function DeclFuncInfo:__init( className, name, argList, staticFlag, accessMode, body, retTypeInfoList ) 

self.className = className
  self.name = name
  self.argList = argList
  self.staticFlag = staticFlag
  self.accessMode = accessMode
  self.body = body
  self.retTypeInfoList = retTypeInfoList
  end
function DeclFuncInfo:get_className()       
  return self.className         
end
function DeclFuncInfo:get_name()       
  return self.name         
end
function DeclFuncInfo:get_argList()       
  return self.argList         
end
function DeclFuncInfo:get_staticFlag()       
  return self.staticFlag         
end
function DeclFuncInfo:get_accessMode()       
  return self.accessMode         
end
function DeclFuncInfo:get_body()       
  return self.body         
end
function DeclFuncInfo:get_retTypeInfoList()       
  return self.retTypeInfoList         
end
do
  end

-- none

function Filter:processDeclFunc( node, ... )
end

-- none

-- none

local nodeKindDeclFunc = regKind( [[DeclFunc]] )

_moduleObj.nodeKindDeclFunc = nodeKindDeclFunc

local DeclFuncNode = {}
setmetatable( DeclFuncNode, { __index = Node } )
_moduleObj.DeclFuncNode = DeclFuncNode
function DeclFuncNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processDeclFunc( self, table.unpack( argList ) )
end
function DeclFuncNode:canBeRight(  )
  return true
end
function DeclFuncNode:canBeLeft(  )
  return false
end
function DeclFuncNode.new( pos, typeList, declInfo )
  local obj = {}
  DeclFuncNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, declInfo ); end
return obj
end
function DeclFuncNode:__init(pos, typeList, declInfo) 
  Node.__init( self, _moduleObj.nodeKindDeclFunc, pos, typeList)
  
  -- none
  
  self.declInfo = declInfo
  -- none
  
end
function DeclFuncNode.setmeta( obj )
  setmetatable( obj, { __index = DeclFuncNode  } )
end
function DeclFuncNode:get_declInfo()       
  return self.declInfo         
end
do
  end


-- none

function Filter:processDeclMethod( node, ... )
end

-- none

-- none

local nodeKindDeclMethod = regKind( [[DeclMethod]] )

_moduleObj.nodeKindDeclMethod = nodeKindDeclMethod

local DeclMethodNode = {}
setmetatable( DeclMethodNode, { __index = Node } )
_moduleObj.DeclMethodNode = DeclMethodNode
function DeclMethodNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processDeclMethod( self, table.unpack( argList ) )
end
function DeclMethodNode:canBeRight(  )
  return false
end
function DeclMethodNode:canBeLeft(  )
  return false
end
function DeclMethodNode.new( pos, typeList, declInfo )
  local obj = {}
  DeclMethodNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, declInfo ); end
return obj
end
function DeclMethodNode:__init(pos, typeList, declInfo) 
  Node.__init( self, _moduleObj.nodeKindDeclMethod, pos, typeList)
  
  -- none
  
  self.declInfo = declInfo
  -- none
  
end
function DeclMethodNode.setmeta( obj )
  setmetatable( obj, { __index = DeclMethodNode  } )
end
function DeclMethodNode:get_declInfo()       
  return self.declInfo         
end
do
  end


-- none

function Filter:processDeclConstr( node, ... )
end

-- none

-- none

local nodeKindDeclConstr = regKind( [[DeclConstr]] )

_moduleObj.nodeKindDeclConstr = nodeKindDeclConstr

local DeclConstrNode = {}
setmetatable( DeclConstrNode, { __index = Node } )
_moduleObj.DeclConstrNode = DeclConstrNode
function DeclConstrNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processDeclConstr( self, table.unpack( argList ) )
end
function DeclConstrNode:canBeRight(  )
  return false
end
function DeclConstrNode:canBeLeft(  )
  return false
end
function DeclConstrNode.new( pos, typeList, declInfo )
  local obj = {}
  DeclConstrNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, declInfo ); end
return obj
end
function DeclConstrNode:__init(pos, typeList, declInfo) 
  Node.__init( self, _moduleObj.nodeKindDeclConstr, pos, typeList)
  
  -- none
  
  self.declInfo = declInfo
  -- none
  
end
function DeclConstrNode.setmeta( obj )
  setmetatable( obj, { __index = DeclConstrNode  } )
end
function DeclConstrNode:get_declInfo()       
  return self.declInfo         
end
do
  end


-- none

function Filter:processDeclDestr( node, ... )
end

-- none

-- none

local nodeKindDeclDestr = regKind( [[DeclDestr]] )

_moduleObj.nodeKindDeclDestr = nodeKindDeclDestr

local DeclDestrNode = {}
setmetatable( DeclDestrNode, { __index = Node } )
_moduleObj.DeclDestrNode = DeclDestrNode
function DeclDestrNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processDeclDestr( self, table.unpack( argList ) )
end
function DeclDestrNode:canBeRight(  )
  return false
end
function DeclDestrNode:canBeLeft(  )
  return false
end
function DeclDestrNode.new( pos, typeList, declInfo )
  local obj = {}
  DeclDestrNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, declInfo ); end
return obj
end
function DeclDestrNode:__init(pos, typeList, declInfo) 
  Node.__init( self, _moduleObj.nodeKindDeclDestr, pos, typeList)
  
  -- none
  
  self.declInfo = declInfo
  -- none
  
end
function DeclDestrNode.setmeta( obj )
  setmetatable( obj, { __index = DeclDestrNode  } )
end
function DeclDestrNode:get_declInfo()       
  return self.declInfo         
end
do
  end


-- none

function Filter:processExpCallSuper( node, ... )
end

-- none

-- none

local nodeKindExpCallSuper = regKind( [[ExpCallSuper]] )

_moduleObj.nodeKindExpCallSuper = nodeKindExpCallSuper

local ExpCallSuperNode = {}
setmetatable( ExpCallSuperNode, { __index = Node } )
_moduleObj.ExpCallSuperNode = ExpCallSuperNode
function ExpCallSuperNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processExpCallSuper( self, table.unpack( argList ) )
end
function ExpCallSuperNode:canBeRight(  )
  return false
end
function ExpCallSuperNode:canBeLeft(  )
  return false
end
function ExpCallSuperNode.new( pos, typeList, superType, expList )
  local obj = {}
  ExpCallSuperNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, superType, expList ); end
return obj
end
function ExpCallSuperNode:__init(pos, typeList, superType, expList) 
  Node.__init( self, _moduleObj.nodeKindExpCallSuper, pos, typeList)
  
  -- none
  
  self.superType = superType
  self.expList = expList
  -- none
  
end
function ExpCallSuperNode.setmeta( obj )
  setmetatable( obj, { __index = ExpCallSuperNode  } )
end
function ExpCallSuperNode:get_superType()       
  return self.superType         
end
function ExpCallSuperNode:get_expList()       
  return self.expList         
end
do
  end


-- none

function Filter:processDeclMember( node, ... )
end

-- none

-- none

local nodeKindDeclMember = regKind( [[DeclMember]] )

_moduleObj.nodeKindDeclMember = nodeKindDeclMember

local DeclMemberNode = {}
setmetatable( DeclMemberNode, { __index = Node } )
_moduleObj.DeclMemberNode = DeclMemberNode
function DeclMemberNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processDeclMember( self, table.unpack( argList ) )
end
function DeclMemberNode:canBeRight(  )
  return false
end
function DeclMemberNode:canBeLeft(  )
  return false
end
function DeclMemberNode.new( pos, typeList, name, refType, symbolInfo, staticFlag, accessMode, getterMutable, getterMode, setterMode )
  local obj = {}
  DeclMemberNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, name, refType, symbolInfo, staticFlag, accessMode, getterMutable, getterMode, setterMode ); end
return obj
end
function DeclMemberNode:__init(pos, typeList, name, refType, symbolInfo, staticFlag, accessMode, getterMutable, getterMode, setterMode) 
  Node.__init( self, _moduleObj.nodeKindDeclMember, pos, typeList)
  
  -- none
  
  self.name = name
  self.refType = refType
  self.symbolInfo = symbolInfo
  self.staticFlag = staticFlag
  self.accessMode = accessMode
  self.getterMutable = getterMutable
  self.getterMode = getterMode
  self.setterMode = setterMode
  -- none
  
end
function DeclMemberNode.setmeta( obj )
  setmetatable( obj, { __index = DeclMemberNode  } )
end
function DeclMemberNode:get_name()       
  return self.name         
end
function DeclMemberNode:get_refType()       
  return self.refType         
end
function DeclMemberNode:get_symbolInfo()       
  return self.symbolInfo         
end
function DeclMemberNode:get_staticFlag()       
  return self.staticFlag         
end
function DeclMemberNode:get_accessMode()       
  return self.accessMode         
end
function DeclMemberNode:get_getterMutable()       
  return self.getterMutable         
end
function DeclMemberNode:get_getterMode()       
  return self.getterMode         
end
function DeclMemberNode:get_setterMode()       
  return self.setterMode         
end
do
  end


-- none

function Filter:processDeclArg( node, ... )
end

-- none

-- none

local nodeKindDeclArg = regKind( [[DeclArg]] )

_moduleObj.nodeKindDeclArg = nodeKindDeclArg

local DeclArgNode = {}
setmetatable( DeclArgNode, { __index = Node } )
_moduleObj.DeclArgNode = DeclArgNode
function DeclArgNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processDeclArg( self, table.unpack( argList ) )
end
function DeclArgNode:canBeRight(  )
  return false
end
function DeclArgNode:canBeLeft(  )
  return false
end
function DeclArgNode.new( pos, typeList, name, argType )
  local obj = {}
  DeclArgNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, name, argType ); end
return obj
end
function DeclArgNode:__init(pos, typeList, name, argType) 
  Node.__init( self, _moduleObj.nodeKindDeclArg, pos, typeList)
  
  -- none
  
  self.name = name
  self.argType = argType
  -- none
  
end
function DeclArgNode.setmeta( obj )
  setmetatable( obj, { __index = DeclArgNode  } )
end
function DeclArgNode:get_name()       
  return self.name         
end
function DeclArgNode:get_argType()       
  return self.argType         
end
do
  end


-- none

function Filter:processDeclArgDDD( node, ... )
end

-- none

-- none

local nodeKindDeclArgDDD = regKind( [[DeclArgDDD]] )

_moduleObj.nodeKindDeclArgDDD = nodeKindDeclArgDDD

local DeclArgDDDNode = {}
setmetatable( DeclArgDDDNode, { __index = Node } )
_moduleObj.DeclArgDDDNode = DeclArgDDDNode
function DeclArgDDDNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processDeclArgDDD( self, table.unpack( argList ) )
end
function DeclArgDDDNode:canBeRight(  )
  return false
end
function DeclArgDDDNode:canBeLeft(  )
  return false
end
function DeclArgDDDNode.new( pos, typeList )
  local obj = {}
  DeclArgDDDNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList ); end
return obj
end
function DeclArgDDDNode:__init(pos, typeList) 
  Node.__init( self, _moduleObj.nodeKindDeclArgDDD, pos, typeList)
  
  -- none
  
  -- none
  
end
function DeclArgDDDNode.setmeta( obj )
  setmetatable( obj, { __index = DeclArgDDDNode  } )
end
do
  end


local AdvertiseInfo = {}
_moduleObj.AdvertiseInfo = AdvertiseInfo
function AdvertiseInfo.setmeta( obj )
  setmetatable( obj, { __index = AdvertiseInfo  } )
end
function AdvertiseInfo.new( member, prefix )
  local obj = {}
  AdvertiseInfo.setmeta( obj )
  if obj.__init then
    obj:__init( member, prefix )
  end        
  return obj 
end         
function AdvertiseInfo:__init( member, prefix ) 

self.member = member
  self.prefix = prefix
  end
function AdvertiseInfo:get_member()       
  return self.member         
end
function AdvertiseInfo:get_prefix()       
  return self.prefix         
end
do
  end

-- none

-- none

function Filter:processDeclClass( node, ... )
end

-- none

-- none

local nodeKindDeclClass = regKind( [[DeclClass]] )

_moduleObj.nodeKindDeclClass = nodeKindDeclClass

local DeclClassNode = {}
setmetatable( DeclClassNode, { __index = Node } )
_moduleObj.DeclClassNode = DeclClassNode
function DeclClassNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processDeclClass( self, table.unpack( argList ) )
end
function DeclClassNode:canBeRight(  )
  return false
end
function DeclClassNode:canBeLeft(  )
  return false
end
function DeclClassNode.new( pos, typeList, accessMode, name, fieldList, moduleName, memberList, scope, initStmtList, advertiseList, trustList, outerMethodSet )
  local obj = {}
  DeclClassNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, accessMode, name, fieldList, moduleName, memberList, scope, initStmtList, advertiseList, trustList, outerMethodSet ); end
return obj
end
function DeclClassNode:__init(pos, typeList, accessMode, name, fieldList, moduleName, memberList, scope, initStmtList, advertiseList, trustList, outerMethodSet) 
  Node.__init( self, _moduleObj.nodeKindDeclClass, pos, typeList)
  
  -- none
  
  self.accessMode = accessMode
  self.name = name
  self.fieldList = fieldList
  self.moduleName = moduleName
  self.memberList = memberList
  self.scope = scope
  self.initStmtList = initStmtList
  self.advertiseList = advertiseList
  self.trustList = trustList
  self.outerMethodSet = outerMethodSet
  -- none
  
end
function DeclClassNode.setmeta( obj )
  setmetatable( obj, { __index = DeclClassNode  } )
end
function DeclClassNode:get_accessMode()       
  return self.accessMode         
end
function DeclClassNode:get_name()       
  return self.name         
end
function DeclClassNode:get_fieldList()       
  return self.fieldList         
end
function DeclClassNode:get_moduleName()       
  return self.moduleName         
end
function DeclClassNode:get_memberList()       
  return self.memberList         
end
function DeclClassNode:get_scope()       
  return self.scope         
end
function DeclClassNode:get_initStmtList()       
  return self.initStmtList         
end
function DeclClassNode:get_advertiseList()       
  return self.advertiseList         
end
function DeclClassNode:get_trustList()       
  return self.trustList         
end
function DeclClassNode:get_outerMethodSet()       
  return self.outerMethodSet         
end
do
  end


-- none

function Filter:processDeclEnum( node, ... )
end

-- none

-- none

local nodeKindDeclEnum = regKind( [[DeclEnum]] )

_moduleObj.nodeKindDeclEnum = nodeKindDeclEnum

local DeclEnumNode = {}
setmetatable( DeclEnumNode, { __index = Node } )
_moduleObj.DeclEnumNode = DeclEnumNode
function DeclEnumNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processDeclEnum( self, table.unpack( argList ) )
end
function DeclEnumNode:canBeRight(  )
  return false
end
function DeclEnumNode:canBeLeft(  )
  return false
end
function DeclEnumNode.new( pos, typeList, accessMode, name, valueNameList, scope )
  local obj = {}
  DeclEnumNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, accessMode, name, valueNameList, scope ); end
return obj
end
function DeclEnumNode:__init(pos, typeList, accessMode, name, valueNameList, scope) 
  Node.__init( self, _moduleObj.nodeKindDeclEnum, pos, typeList)
  
  -- none
  
  self.accessMode = accessMode
  self.name = name
  self.valueNameList = valueNameList
  self.scope = scope
  -- none
  
end
function DeclEnumNode.setmeta( obj )
  setmetatable( obj, { __index = DeclEnumNode  } )
end
function DeclEnumNode:get_accessMode()       
  return self.accessMode         
end
function DeclEnumNode:get_name()       
  return self.name         
end
function DeclEnumNode:get_valueNameList()       
  return self.valueNameList         
end
function DeclEnumNode:get_scope()       
  return self.scope         
end
do
  end


-- none

function Filter:processDeclMacro( node, ... )
end

-- none

-- none

local nodeKindDeclMacro = regKind( [[DeclMacro]] )

_moduleObj.nodeKindDeclMacro = nodeKindDeclMacro

local DeclMacroNode = {}
setmetatable( DeclMacroNode, { __index = Node } )
_moduleObj.DeclMacroNode = DeclMacroNode
function DeclMacroNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processDeclMacro( self, table.unpack( argList ) )
end
function DeclMacroNode:canBeRight(  )
  return false
end
function DeclMacroNode:canBeLeft(  )
  return false
end
function DeclMacroNode.new( pos, typeList, declInfo )
  local obj = {}
  DeclMacroNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, declInfo ); end
return obj
end
function DeclMacroNode:__init(pos, typeList, declInfo) 
  Node.__init( self, _moduleObj.nodeKindDeclMacro, pos, typeList)
  
  -- none
  
  self.declInfo = declInfo
  -- none
  
end
function DeclMacroNode.setmeta( obj )
  setmetatable( obj, { __index = DeclMacroNode  } )
end
function DeclMacroNode:get_declInfo()       
  return self.declInfo         
end
do
  end


local MacroEval = {}
_moduleObj.MacroEval = MacroEval
-- none
function MacroEval.setmeta( obj )
  setmetatable( obj, { __index = MacroEval  } )
end
function MacroEval.new(  )
  local obj = {}
  MacroEval.setmeta( obj )
  if obj.__init then
    obj:__init(  )
  end        
  return obj 
end         
function MacroEval:__init(  ) 

end
do
  end

-- none

function Filter:processLiteralNil( node, ... )
end

-- none

-- none

local nodeKindLiteralNil = regKind( [[LiteralNil]] )

_moduleObj.nodeKindLiteralNil = nodeKindLiteralNil

local LiteralNilNode = {}
setmetatable( LiteralNilNode, { __index = Node } )
_moduleObj.LiteralNilNode = LiteralNilNode
function LiteralNilNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processLiteralNil( self, table.unpack( argList ) )
end
function LiteralNilNode:canBeRight(  )
  return true
end
function LiteralNilNode:canBeLeft(  )
  return false
end
function LiteralNilNode.new( pos, typeList )
  local obj = {}
  LiteralNilNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList ); end
return obj
end
function LiteralNilNode:__init(pos, typeList) 
  Node.__init( self, _moduleObj.nodeKindLiteralNil, pos, typeList)
  
  -- none
  
  -- none
  
end
function LiteralNilNode.setmeta( obj )
  setmetatable( obj, { __index = LiteralNilNode  } )
end
do
  end


-- none

function Filter:processLiteralChar( node, ... )
end

-- none

-- none

local nodeKindLiteralChar = regKind( [[LiteralChar]] )

_moduleObj.nodeKindLiteralChar = nodeKindLiteralChar

local LiteralCharNode = {}
setmetatable( LiteralCharNode, { __index = Node } )
_moduleObj.LiteralCharNode = LiteralCharNode
function LiteralCharNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processLiteralChar( self, table.unpack( argList ) )
end
function LiteralCharNode:canBeRight(  )
  return true
end
function LiteralCharNode:canBeLeft(  )
  return false
end
function LiteralCharNode.new( pos, typeList, token, num )
  local obj = {}
  LiteralCharNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, token, num ); end
return obj
end
function LiteralCharNode:__init(pos, typeList, token, num) 
  Node.__init( self, _moduleObj.nodeKindLiteralChar, pos, typeList)
  
  -- none
  
  self.token = token
  self.num = num
  -- none
  
end
function LiteralCharNode.setmeta( obj )
  setmetatable( obj, { __index = LiteralCharNode  } )
end
function LiteralCharNode:get_token()       
  return self.token         
end
function LiteralCharNode:get_num()       
  return self.num         
end
do
  end


-- none

function Filter:processLiteralInt( node, ... )
end

-- none

-- none

local nodeKindLiteralInt = regKind( [[LiteralInt]] )

_moduleObj.nodeKindLiteralInt = nodeKindLiteralInt

local LiteralIntNode = {}
setmetatable( LiteralIntNode, { __index = Node } )
_moduleObj.LiteralIntNode = LiteralIntNode
function LiteralIntNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processLiteralInt( self, table.unpack( argList ) )
end
function LiteralIntNode:canBeRight(  )
  return true
end
function LiteralIntNode:canBeLeft(  )
  return false
end
function LiteralIntNode.new( pos, typeList, token, num )
  local obj = {}
  LiteralIntNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, token, num ); end
return obj
end
function LiteralIntNode:__init(pos, typeList, token, num) 
  Node.__init( self, _moduleObj.nodeKindLiteralInt, pos, typeList)
  
  -- none
  
  self.token = token
  self.num = num
  -- none
  
end
function LiteralIntNode.setmeta( obj )
  setmetatable( obj, { __index = LiteralIntNode  } )
end
function LiteralIntNode:get_token()       
  return self.token         
end
function LiteralIntNode:get_num()       
  return self.num         
end
do
  end


-- none

function Filter:processLiteralReal( node, ... )
end

-- none

-- none

local nodeKindLiteralReal = regKind( [[LiteralReal]] )

_moduleObj.nodeKindLiteralReal = nodeKindLiteralReal

local LiteralRealNode = {}
setmetatable( LiteralRealNode, { __index = Node } )
_moduleObj.LiteralRealNode = LiteralRealNode
function LiteralRealNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processLiteralReal( self, table.unpack( argList ) )
end
function LiteralRealNode:canBeRight(  )
  return true
end
function LiteralRealNode:canBeLeft(  )
  return false
end
function LiteralRealNode.new( pos, typeList, token, num )
  local obj = {}
  LiteralRealNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, token, num ); end
return obj
end
function LiteralRealNode:__init(pos, typeList, token, num) 
  Node.__init( self, _moduleObj.nodeKindLiteralReal, pos, typeList)
  
  -- none
  
  self.token = token
  self.num = num
  -- none
  
end
function LiteralRealNode.setmeta( obj )
  setmetatable( obj, { __index = LiteralRealNode  } )
end
function LiteralRealNode:get_token()       
  return self.token         
end
function LiteralRealNode:get_num()       
  return self.num         
end
do
  end


-- none

function Filter:processLiteralArray( node, ... )
end

-- none

-- none

local nodeKindLiteralArray = regKind( [[LiteralArray]] )

_moduleObj.nodeKindLiteralArray = nodeKindLiteralArray

local LiteralArrayNode = {}
setmetatable( LiteralArrayNode, { __index = Node } )
_moduleObj.LiteralArrayNode = LiteralArrayNode
function LiteralArrayNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processLiteralArray( self, table.unpack( argList ) )
end
function LiteralArrayNode:canBeRight(  )
  return true
end
function LiteralArrayNode:canBeLeft(  )
  return false
end
function LiteralArrayNode.new( pos, typeList, expList )
  local obj = {}
  LiteralArrayNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, expList ); end
return obj
end
function LiteralArrayNode:__init(pos, typeList, expList) 
  Node.__init( self, _moduleObj.nodeKindLiteralArray, pos, typeList)
  
  -- none
  
  self.expList = expList
  -- none
  
end
function LiteralArrayNode.setmeta( obj )
  setmetatable( obj, { __index = LiteralArrayNode  } )
end
function LiteralArrayNode:get_expList()       
  return self.expList         
end
do
  end


-- none

function Filter:processLiteralList( node, ... )
end

-- none

-- none

local nodeKindLiteralList = regKind( [[LiteralList]] )

_moduleObj.nodeKindLiteralList = nodeKindLiteralList

local LiteralListNode = {}
setmetatable( LiteralListNode, { __index = Node } )
_moduleObj.LiteralListNode = LiteralListNode
function LiteralListNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processLiteralList( self, table.unpack( argList ) )
end
function LiteralListNode:canBeRight(  )
  return true
end
function LiteralListNode:canBeLeft(  )
  return false
end
function LiteralListNode.new( pos, typeList, expList )
  local obj = {}
  LiteralListNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, expList ); end
return obj
end
function LiteralListNode:__init(pos, typeList, expList) 
  Node.__init( self, _moduleObj.nodeKindLiteralList, pos, typeList)
  
  -- none
  
  self.expList = expList
  -- none
  
end
function LiteralListNode.setmeta( obj )
  setmetatable( obj, { __index = LiteralListNode  } )
end
function LiteralListNode:get_expList()       
  return self.expList         
end
do
  end


local PairItem = {}
_moduleObj.PairItem = PairItem
function PairItem.setmeta( obj )
  setmetatable( obj, { __index = PairItem  } )
end
function PairItem.new( key, val )
  local obj = {}
  PairItem.setmeta( obj )
  if obj.__init then
    obj:__init( key, val )
  end        
  return obj 
end         
function PairItem:__init( key, val ) 

self.key = key
  self.val = val
  end
function PairItem:get_key()       
  return self.key         
end
function PairItem:get_val()       
  return self.val         
end
do
  end

-- none

function Filter:processLiteralMap( node, ... )
end

-- none

-- none

local nodeKindLiteralMap = regKind( [[LiteralMap]] )

_moduleObj.nodeKindLiteralMap = nodeKindLiteralMap

local LiteralMapNode = {}
setmetatable( LiteralMapNode, { __index = Node } )
_moduleObj.LiteralMapNode = LiteralMapNode
function LiteralMapNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processLiteralMap( self, table.unpack( argList ) )
end
function LiteralMapNode:canBeRight(  )
  return true
end
function LiteralMapNode:canBeLeft(  )
  return false
end
function LiteralMapNode.new( pos, typeList, map, pairList )
  local obj = {}
  LiteralMapNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, map, pairList ); end
return obj
end
function LiteralMapNode:__init(pos, typeList, map, pairList) 
  Node.__init( self, _moduleObj.nodeKindLiteralMap, pos, typeList)
  
  -- none
  
  self.map = map
  self.pairList = pairList
  -- none
  
end
function LiteralMapNode.setmeta( obj )
  setmetatable( obj, { __index = LiteralMapNode  } )
end
function LiteralMapNode:get_map()       
  return self.map         
end
function LiteralMapNode:get_pairList()       
  return self.pairList         
end
do
  end


-- none

function Filter:processLiteralString( node, ... )
end

-- none

-- none

local nodeKindLiteralString = regKind( [[LiteralString]] )

_moduleObj.nodeKindLiteralString = nodeKindLiteralString

local LiteralStringNode = {}
setmetatable( LiteralStringNode, { __index = Node } )
_moduleObj.LiteralStringNode = LiteralStringNode
function LiteralStringNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processLiteralString( self, table.unpack( argList ) )
end
function LiteralStringNode:canBeRight(  )
  return true
end
function LiteralStringNode:canBeLeft(  )
  return false
end
function LiteralStringNode.new( pos, typeList, token, argList )
  local obj = {}
  LiteralStringNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, token, argList ); end
return obj
end
function LiteralStringNode:__init(pos, typeList, token, argList) 
  Node.__init( self, _moduleObj.nodeKindLiteralString, pos, typeList)
  
  -- none
  
  self.token = token
  self.argList = argList
  -- none
  
end
function LiteralStringNode.setmeta( obj )
  setmetatable( obj, { __index = LiteralStringNode  } )
end
function LiteralStringNode:get_token()       
  return self.token         
end
function LiteralStringNode:get_argList()       
  return self.argList         
end
do
  end


-- none

function Filter:processLiteralBool( node, ... )
end

-- none

-- none

local nodeKindLiteralBool = regKind( [[LiteralBool]] )

_moduleObj.nodeKindLiteralBool = nodeKindLiteralBool

local LiteralBoolNode = {}
setmetatable( LiteralBoolNode, { __index = Node } )
_moduleObj.LiteralBoolNode = LiteralBoolNode
function LiteralBoolNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processLiteralBool( self, table.unpack( argList ) )
end
function LiteralBoolNode:canBeRight(  )
  return true
end
function LiteralBoolNode:canBeLeft(  )
  return false
end
function LiteralBoolNode.new( pos, typeList, token )
  local obj = {}
  LiteralBoolNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, token ); end
return obj
end
function LiteralBoolNode:__init(pos, typeList, token) 
  Node.__init( self, _moduleObj.nodeKindLiteralBool, pos, typeList)
  
  -- none
  
  self.token = token
  -- none
  
end
function LiteralBoolNode.setmeta( obj )
  setmetatable( obj, { __index = LiteralBoolNode  } )
end
function LiteralBoolNode:get_token()       
  return self.token         
end
do
  end


-- none

function Filter:processLiteralSymbol( node, ... )
end

-- none

-- none

local nodeKindLiteralSymbol = regKind( [[LiteralSymbol]] )

_moduleObj.nodeKindLiteralSymbol = nodeKindLiteralSymbol

local LiteralSymbolNode = {}
setmetatable( LiteralSymbolNode, { __index = Node } )
_moduleObj.LiteralSymbolNode = LiteralSymbolNode
function LiteralSymbolNode:processFilter( filter, ... )
  local argList = {...}
  
  filter:processLiteralSymbol( self, table.unpack( argList ) )
end
function LiteralSymbolNode:canBeRight(  )
  return true
end
function LiteralSymbolNode:canBeLeft(  )
  return false
end
function LiteralSymbolNode.new( pos, typeList, token )
  local obj = {}
  LiteralSymbolNode.setmeta( obj )
  if obj.__init then obj:__init( pos, typeList, token ); end
return obj
end
function LiteralSymbolNode:__init(pos, typeList, token) 
  Node.__init( self, _moduleObj.nodeKindLiteralSymbol, pos, typeList)
  
  -- none
  
  self.token = token
  -- none
  
end
function LiteralSymbolNode.setmeta( obj )
  setmetatable( obj, { __index = LiteralSymbolNode  } )
end
function LiteralSymbolNode:get_token()       
  return self.token         
end
do
  end


function Node:getSymbolInfo(  )
  local function processExpNode( node )
    do
      local _switchExp = (node:get_kind() )
      if _switchExp == _moduleObj.nodeKindExpRef then
        return {(node ):get_symbolInfo()}
      elseif _switchExp == _moduleObj.nodeKindRefField then
        local refFieldNode = node
        
        do
          local _exp = refFieldNode:get_symbolInfo()
          if _exp ~= nil then
          
              return {_exp}
            end
        end
        
        return {}
      elseif _switchExp == _moduleObj.nodeKindGetField then
        local getFieldNode = node
        
        do
          local _exp = getFieldNode:get_symbolInfo()
          if _exp ~= nil then
          
              return {_exp}
            end
        end
        
        return {}
      elseif _switchExp == _moduleObj.nodeKindExpList then
        local expListNode = node
        
        local list = {}
        
        for index, expNode in pairs( expListNode:get_expList() ) do
          if index == #expListNode:get_expList() then
            for __index, symbolInfo in pairs( processExpNode( expNode ) ) do
              table.insert( list, symbolInfo )
            end
          else 
            for __index, symbolInfo in pairs( processExpNode( expNode ) ) do
              table.insert( list, symbolInfo )
              break
            end
          end
        end
        return list
      end
    end
    
    return {}
  end
  
  return processExpNode( self )
end

function LiteralNilNode:getLiteral(  )
  return {nil}, {_moduleObj.builtinTypeNil}
end

function LiteralCharNode:getLiteral(  )
  return {self.num}, {_moduleObj.builtinTypeChar}
end

function LiteralIntNode:getLiteral(  )
  return {self.num}, {_moduleObj.builtinTypeInt}
end

function LiteralRealNode:getLiteral(  )
  return {self.num}, {_moduleObj.builtinTypeReal}
end

function LiteralArrayNode:getLiteral(  )
  local array = {}
  
  do
    local _exp = self.expList
    if _exp ~= nil then
    
        for __index, val in pairs( _exp:get_expList(  ) ) do
          local txt = val:getLiteral(  )[1]
          
              if  nil == txt then
                local _txt = txt
                
                return {}, {}
              end
            
          table.insert( array, txt )
        end
      end
  end
  
  return {array}, {self:get_expType(  )}
end

function LiteralListNode:getLiteral(  )
  local list = {}
  
  do
    local _exp = self.expList
    if _exp ~= nil then
    
        for __index, val in pairs( _exp:get_expList(  ) ) do
          local item = val:getLiteral(  )[1]
          
              if  nil == item then
                local _item = item
                
                return {}, {}
              end
            
          table.insert( list, item )
        end
      end
  end
  
  return {list}, {self:get_expType(  )}
end

function LiteralMapNode:getLiteral(  )
  local map = {}
  
  for key, val in pairs( self.map ) do
    map[key:getLiteral(  )[1]] = val:getLiteral(  )[1]
  end
  return {map}, {self:get_expType(  )}
end

function LiteralStringNode:getLiteral(  )
  local txt = self.token.txt
  
  if string.find( txt, '^```' ) then
    txt = txt:sub( 4, -4 )
  else 
    txt = txt:sub( 2, -2 )
  end
  local argList = self:get_argList()
  
  if #argList > 0 then
    local argTbl = {}
    
    for __index, argNode in pairs( argList ) do
      local arg = argNode:getLiteral(  )
      
      if #arg > 1 then
        local argTxt = arg[1]
        
            if  nil == argTxt then
              local _argTxt = argTxt
              
              return {}, {}
            end
          
        table.insert( argTbl, argTxt )
      end
    end
    return {string.format( txt, table.unpack( argTbl ) )}, {_moduleObj.builtinTypeString}
  end
  return {txt}, {_moduleObj.builtinTypeString}
end

function LiteralBoolNode:getLiteral(  )
  return {self.token.txt == "true"}, {_moduleObj.builtinTypeBool}
end

function LiteralSymbolNode:getLiteral(  )
  return {{self.token.txt}}, {_moduleObj.builtinTypeSymbol}
end

function RefFieldNode:getLiteral(  )
  local prefix = (_lune.unwrap( self.prefix:getLiteral(  )[1]) )
  
  if self.nilAccess then
    table.insert( prefix, "$." )
  else 
    table.insert( prefix, "." )
  end
  table.insert( prefix, self.field.txt )
  return {prefix}, {_moduleObj.builtinTypeSymbol}
end

function ExpMacroStatNode:getLiteral(  )
  local txt = ""
  
  for __index, token in pairs( self.expStrList ) do
    txt = string.format( "%s%s", txt, token:getLiteral(  )[1])
  end
  return {txt}, {self:get_expType(  )}
end

function ExpRefNode:getLiteral(  )
  local typeInfo = self.symbolInfo:get_typeInfo()
  
  if typeInfo:get_kind() ~= TypeInfoKind.Enum then
    return {}, {}
  end
  local enumTypeInfo = typeInfo
  
  local val = _lune.unwrap( enumTypeInfo:getEnumValInfo( self.symbolInfo:get_name() ))
  
  return {val:get_val()}, {enumTypeInfo:get_valTypeInfo()}
end

function ExpOp2Node:getLiteral(  )
  local val1List, type1List = self:get_exp1():getLiteral(  )
  
  local val2List, type2List = self:get_exp2():getLiteral(  )
  
  if #val1List ~= 1 or #type1List ~= 1 or #val2List ~= 1 or #type2List ~= 1 then
    return {}, {}
  end
  local val1, type1, val2, type2 = _lune.unwrap( val1List[1]), type1List[1]:get_srcTypeInfo(), _lune.unwrap( val2List[1]), type2List[1]:get_srcTypeInfo()
  
  if (type1 == _moduleObj.builtinTypeInt or type1 == _moduleObj.builtinTypeReal ) and (type2 == _moduleObj.builtinTypeInt or type2 == _moduleObj.builtinTypeReal ) then
    local retType = _moduleObj.builtinTypeInt
    
    if type1 == _moduleObj.builtinTypeReal or type2 == _moduleObj.builtinTypeReal then
      retType = _moduleObj.builtinTypeReal
    end
    local int1, int2 = 0, 0
    
    local real1, real2 = 0.0, 0.0
    
    if type1 == _moduleObj.builtinTypeInt then
      int1 = math.floor(val1)
      real1 = int1
    else 
      real1 = val1
    end
    if type2 == _moduleObj.builtinTypeInt then
      int2 = math.floor(val2)
      real2 = int2
    else 
      real2 = val2
    end
    do
      local _switchExp = (self.op.txt )
      if _switchExp == "+" then
        if retType == _moduleObj.builtinTypeInt then
          return {int1 + int2}, {retType}
        end
        return {real1 + real2}, {retType}
      elseif _switchExp == "-" then
        if retType == _moduleObj.builtinTypeInt then
          return {int1 - int2}, {retType}
        end
        return {real1 - real2}, {retType}
      elseif _switchExp == "*" then
        if retType == _moduleObj.builtinTypeInt then
          return {int1 * int2}, {retType}
        end
        return {real1 * real2}, {retType}
      elseif _switchExp == "/" then
        if retType == _moduleObj.builtinTypeInt then
          return {math.floor(int1 / int2)}, {retType}
        end
        return {real1 / real2}, {retType}
      end
    end
    
  elseif type1 == _moduleObj.builtinTypeString and type2 == _moduleObj.builtinTypeString then
    if self.op.txt == ".." then
      return {val1 .. val2}, {_moduleObj.builtinTypeString}
    end
  end
  return {}, {}
end

return _moduleObj
