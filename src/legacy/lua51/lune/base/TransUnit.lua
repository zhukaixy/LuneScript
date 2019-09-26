--lune/base/TransUnit.lns
local _moduleObj = {}
local __mod__ = '@lune.@base.@TransUnit'
local _lune = {}
if _lune1 then
   _lune = _lune1
end
function _lune.newAlge( kind, vals )
   local memInfoList = kind[ 2 ]
   if not memInfoList then
      return kind
   end
   return { kind[ 1 ], vals }
end

function _lune._fromList( obj, list, memInfoList )
   if type( list ) ~= "table" then
      return false
   end
   for index, memInfo in ipairs( memInfoList ) do
      local val, key = memInfo.func( list[ index ], memInfo.child )
      if val == nil and not memInfo.nilable then
         return false, key and string.format( "%s[%s]", memInfo.name, key) or memInfo.name
      end
      obj[ index ] = val
   end
   return true
end
function _lune._AlgeFrom( Alge, val )
   local work = Alge._name2Val[ val[ 1 ] ]
   if not work then
      return nil
   end
   if #work == 1 then
     return work
   end
   local paramList = {}
   local result, mess = _lune._fromList( paramList, val[ 2 ], work[ 2 ] )
   if not result then
      return nil, mess
   end
   return { work[ 1 ], paramList }
end

function _lune._Set_or( setObj, otherSet )
   for val in pairs( otherSet ) do
      setObj[ val ] = true
   end
   return setObj
end
function _lune._Set_and( setObj, otherSet )
   local delValList = {}
   for val in pairs( setObj ) do
      if not otherSet[ val ] then
         table.insert( delValList, val )
      end
   end
   for index, val in ipairs( delValList ) do
      setObj[ val ] = nil
   end
   return setObj
end
function _lune._Set_has( setObj, val )
   return setObj[ val ] ~= nil
end
function _lune._Set_sub( setObj, otherSet )
   local delValList = {}
   for val in pairs( setObj ) do
      if otherSet[ val ] then
         table.insert( delValList, val )
      end
   end
   for index, val in ipairs( delValList ) do
      setObj[ val ] = nil
   end
   return setObj
end
function _lune._Set_len( setObj )
   local total = 0
   for val in pairs( setObj ) do
      total = total + 1
   end
   return total
end
function _lune._Set_clone( setObj )
   local obj = {}
   for val in pairs( setObj ) do
      obj[ val ] = true
   end
   return obj
end

function _lune._toSet( val, toKeyInfo )
   if type( val ) == "table" then
      local tbl = {}
      for key, mem in pairs( val ) do
         local mapKey, keySub = toKeyInfo.func( key, toKeyInfo.child )
         local mapVal = _lune._toBool( mem )
         if mapKey == nil or mapVal == nil then
            if mapKey == nil then
               return nil
            end
            if keySub == nil then
               return nil, mapKey
            end
            return nil, string.format( "%s.%s", mapKey, keySub)
         end
         tbl[ mapKey ] = mapVal
      end
      return tbl
   end
   return nil
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

function _lune._toStem( val )
   return val
end
function _lune._toInt( val )
   if type( val ) == "number" then
      return math.floor( val )
   end
   return nil
end
function _lune._toReal( val )
   if type( val ) == "number" then
      return val
   end
   return nil
end
function _lune._toBool( val )
   if type( val ) == "boolean" then
      return val
   end
   return nil
end
function _lune._toStr( val )
   if type( val ) == "string" then
      return val
   end
   return nil
end
function _lune._toList( val, toValInfoList )
   if type( val ) == "table" then
      local tbl = {}
      local toValInfo = toValInfoList[ 1 ]
      for index, mem in ipairs( val ) do
         local memval, mess = toValInfo.func( mem, toValInfo.child )
         if memval == nil and not toValInfo.nilable then
            if mess then
              return nil, string.format( "%d.%s", index, mess )
            end
            return nil, index
         end
         tbl[ index ] = memval
      end
      return tbl
   end
   return nil
end
function _lune._toMap( val, toValInfoList )
   if type( val ) == "table" then
      local tbl = {}
      local toKeyInfo = toValInfoList[ 1 ]
      local toValInfo = toValInfoList[ 2 ]
      for key, mem in pairs( val ) do
         local mapKey, keySub = toKeyInfo.func( key, toKeyInfo.child )
         local mapVal, valSub = toValInfo.func( mem, toValInfo.child )
         if mapKey == nil or mapVal == nil then
            if mapKey == nil then
               return nil
            end
            if keySub == nil then
               return nil, mapKey
            end
            return nil, string.format( "%s.%s", mapKey, keySub)
         end
         tbl[ mapKey ] = mapVal
      end
      return tbl
   end
   return nil
end
function _lune._fromMap( obj, map, memInfoList )
   if type( map ) ~= "table" then
      return false
   end
   for index, memInfo in ipairs( memInfoList ) do
      local val, key = memInfo.func( map[ memInfo.name ], memInfo.child )
      if val == nil and not memInfo.nilable then
         return false, key and string.format( "%s.%s", memInfo.name, key) or memInfo.name
      end
      obj[ memInfo.name ] = val
   end
   return true
end

function _lune.loadModule( mod )
   if __luneScript then
      return  __luneScript:loadModule( mod )
   end
   return require( mod )
end

function _lune.__isInstanceOf( obj, class )
   while obj do
      local meta = getmetatable( obj )
      if not meta then
	 return false
      end
      local indexTbl = meta.__index
      if indexTbl == class then
	 return true
      end
      if meta.ifList then
         for index, ifType in ipairs( meta.ifList ) do
            if _lune.__isInstanceOf( ifType, class ) then
               return true
            end
         end
      end
      obj = indexTbl
   end
   return false
end

function _lune.__Cast( obj, kind, class )
   if kind == 0 then -- int
      if type( obj ) ~= "number" then
         return nil
      end
      if math.floor( obj ) ~= obj then
         return nil
      end
      return obj
   elseif kind == 1 then -- real
      if type( obj ) ~= "number" then
         return nil
      end
      return obj
   elseif kind == 2 then -- str
      if type( obj ) ~= "string" then
         return nil
      end
      return obj
   elseif kind == 3 then -- class
      return _lune.__isInstanceOf( obj, class ) and obj or nil
   end
   return nil
end

if not _lune1 then
   _lune1 = _lune
end



local Parser = _lune.loadModule( 'lune.base.Parser' )
local Util = _lune.loadModule( 'lune.base.Util' )
local Ast = _lune.loadModule( 'lune.base.Ast' )
local Nodes = _lune.loadModule( 'lune.base.Nodes' )
local Writer = _lune.loadModule( 'lune.base.Writer' )
local frontInterface = _lune.loadModule( 'lune.base.frontInterface' )
local LuaVer = _lune.loadModule( 'lune.base.LuaVer' )
local Option = _lune.loadModule( 'lune.base.Option' )
local Code = _lune.loadModule( 'lune.base.Code' )
local Log = _lune.loadModule( 'lune.base.Log' )
local LuneControl = _lune.loadModule( 'lune.base.LuneControl' )

local DeclClassMode = {}
DeclClassMode._val2NameMap = {}
function DeclClassMode:_getTxt( val )
   local name = self._val2NameMap[ val ]
   if name then
      return string.format( "DeclClassMode.%s", name )
   end
   return string.format( "illegal val -- %s", val )
end
function DeclClassMode._from( val )
   if DeclClassMode._val2NameMap[ val ] then
      return val
   end
   return nil
end
    
DeclClassMode.__allList = {}
function DeclClassMode.get__allList()
   return DeclClassMode.__allList
end

DeclClassMode.Class = 0
DeclClassMode._val2NameMap[0] = 'Class'
DeclClassMode.__allList[1] = DeclClassMode.Class
DeclClassMode.Interface = 1
DeclClassMode._val2NameMap[1] = 'Interface'
DeclClassMode.__allList[2] = DeclClassMode.Interface
DeclClassMode.Module = 2
DeclClassMode._val2NameMap[2] = 'Module'
DeclClassMode.__allList[3] = DeclClassMode.Module

local DeclFuncMode = {}
DeclFuncMode._val2NameMap = {}
function DeclFuncMode:_getTxt( val )
   local name = self._val2NameMap[ val ]
   if name then
      return string.format( "DeclFuncMode.%s", name )
   end
   return string.format( "illegal val -- %s", val )
end
function DeclFuncMode._from( val )
   if DeclFuncMode._val2NameMap[ val ] then
      return val
   end
   return nil
end
    
DeclFuncMode.__allList = {}
function DeclFuncMode.get__allList()
   return DeclFuncMode.__allList
end

DeclFuncMode.Func = 0
DeclFuncMode._val2NameMap[0] = 'Func'
DeclFuncMode.__allList[1] = DeclFuncMode.Func
DeclFuncMode.Class = 1
DeclFuncMode._val2NameMap[1] = 'Class'
DeclFuncMode.__allList[2] = DeclFuncMode.Class
DeclFuncMode.Module = 2
DeclFuncMode._val2NameMap[2] = 'Module'
DeclFuncMode.__allList[3] = DeclFuncMode.Module
DeclFuncMode.Glue = 3
DeclFuncMode._val2NameMap[3] = 'Glue'
DeclFuncMode.__allList[4] = DeclFuncMode.Glue

local ExpSymbolMode = {}
ExpSymbolMode._val2NameMap = {}
function ExpSymbolMode:_getTxt( val )
   local name = self._val2NameMap[ val ]
   if name then
      return string.format( "ExpSymbolMode.%s", name )
   end
   return string.format( "illegal val -- %s", val )
end
function ExpSymbolMode._from( val )
   if ExpSymbolMode._val2NameMap[ val ] then
      return val
   end
   return nil
end
    
ExpSymbolMode.__allList = {}
function ExpSymbolMode.get__allList()
   return ExpSymbolMode.__allList
end

ExpSymbolMode.Symbol = 0
ExpSymbolMode._val2NameMap[0] = 'Symbol'
ExpSymbolMode.__allList[1] = ExpSymbolMode.Symbol
ExpSymbolMode.Fn = 1
ExpSymbolMode._val2NameMap[1] = 'Fn'
ExpSymbolMode.__allList[2] = ExpSymbolMode.Fn
ExpSymbolMode.Field = 2
ExpSymbolMode._val2NameMap[2] = 'Field'
ExpSymbolMode.__allList[3] = ExpSymbolMode.Field
ExpSymbolMode.FieldNil = 3
ExpSymbolMode._val2NameMap[3] = 'FieldNil'
ExpSymbolMode.__allList[4] = ExpSymbolMode.FieldNil
ExpSymbolMode.Get = 4
ExpSymbolMode._val2NameMap[4] = 'Get'
ExpSymbolMode.__allList[5] = ExpSymbolMode.Get
ExpSymbolMode.GetNil = 5
ExpSymbolMode._val2NameMap[5] = 'GetNil'
ExpSymbolMode.__allList[6] = ExpSymbolMode.GetNil

local AnalyzeMode = {}
_moduleObj.AnalyzeMode = AnalyzeMode
AnalyzeMode._val2NameMap = {}
function AnalyzeMode:_getTxt( val )
   local name = self._val2NameMap[ val ]
   if name then
      return string.format( "AnalyzeMode.%s", name )
   end
   return string.format( "illegal val -- %s", val )
end
function AnalyzeMode._from( val )
   if AnalyzeMode._val2NameMap[ val ] then
      return val
   end
   return nil
end
    
AnalyzeMode.__allList = {}
function AnalyzeMode.get__allList()
   return AnalyzeMode.__allList
end

AnalyzeMode.Compile = 0
AnalyzeMode._val2NameMap[0] = 'Compile'
AnalyzeMode.__allList[1] = AnalyzeMode.Compile
AnalyzeMode.Diag = 1
AnalyzeMode._val2NameMap[1] = 'Diag'
AnalyzeMode.__allList[2] = AnalyzeMode.Diag
AnalyzeMode.Complete = 2
AnalyzeMode._val2NameMap[2] = 'Complete'
AnalyzeMode.__allList[3] = AnalyzeMode.Complete

local TentativeSymbol = {}
function TentativeSymbol.new( parent, scope, loopFlag )
   local obj = {}
   TentativeSymbol.setmeta( obj )
   if obj.__init then obj:__init( parent, scope, loopFlag ); end
   return obj
end
function TentativeSymbol:__init(parent, scope, loopFlag) 
   self.symbolSet = {}
   self.oldSymbolSet = nil
   self.parent = parent
   self.scope = scope
   self.skipFlag = false
   self.loopFlag = loopFlag
end
function TentativeSymbol:checkAndExclude( symbolInfo )

   symbolInfo = symbolInfo:getOrg(  )
   if _lune._Set_has(self.symbolSet, symbolInfo ) then
      self.symbolSet[symbolInfo]= nil
      return true
   end
   
   return false
end
function TentativeSymbol:regist( symbolInfo )

   self.symbolSet[symbolInfo:getOrg(  )]= true
   symbolInfo:set_hasValueFlag( true )
   if self.scope:isInnerOf( symbolInfo:get_scope() ) then
      if not symbolInfo:get_mutable() then
         local work = self
         while true do
            do
               local _exp = work.parent
               if _exp ~= nil then
                  if work.scope == symbolInfo:get_scope() then
                     break
                  end
                  
                  if work.loopFlag then
                     return false
                  end
                  
                  work = _exp
               else
                  break
               end
            end
            
         end
         
      end
      
   end
   
   return true
end
function TentativeSymbol:skip(  )

   for symbolInfo, __val in pairs( self.symbolSet ) do
      symbolInfo:set_hasValueFlag( false )
   end
   
   self.skipFlag = true
end
function TentativeSymbol:merge( finishFlag )

   if self.skipFlag then
      self.skipFlag = false
      do
         local other = self.oldSymbolSet
         if other ~= nil then
            self.symbolSet = _lune._Set_clone(other )
         end
      end
      
      if finishFlag then
         for symbolInfo, __val in pairs( self.symbolSet ) do
            symbolInfo:set_hasValueFlag( true )
         end
         
      end
      
      return 
   end
   
   do
      local other = self.oldSymbolSet
      if other ~= nil then
         local mergedSet = _lune._Set_and(_lune._Set_clone(self.symbolSet ), other )
         if finishFlag then
            for symbolInfo, __val in pairs( _lune._Set_sub(_lune._Set_or(_lune._Set_clone(self.symbolSet ), other ), mergedSet ) ) do
               symbolInfo:set_hasValueFlag( false )
            end
            
         else
          
            for symbolInfo, __val in pairs( _lune._Set_or(_lune._Set_clone(self.symbolSet ), other ) ) do
               symbolInfo:set_hasValueFlag( false )
            end
            
         end
         
         self.symbolSet = mergedSet
      else
         if not finishFlag then
            for symbolInfo, __val in pairs( self.symbolSet ) do
               symbolInfo:set_hasValueFlag( false )
            end
            
         end
         
      end
   end
   
end
function TentativeSymbol:finish( complete )

   self:merge( true )
   do
      local parent = self.parent
      if parent ~= nil then
         if complete then
            for symbolInfo, __val in pairs( self.symbolSet ) do
               if symbolInfo:get_hasValueFlag() then
                  if parent.scope:isInnerOf( symbolInfo:get_scope() ) then
                     parent.symbolSet[symbolInfo]= true
                  end
                  
               end
               
            end
            
         else
          
            for symbolInfo, __val in pairs( self.symbolSet ) do
               symbolInfo:set_hasValueFlag( false )
            end
            
         end
         
         return parent
      end
   end
   
   return nil
end
function TentativeSymbol:newSet( scope )

   self:merge( false )
   self.oldSymbolSet = self.symbolSet
   self.symbolSet = {}
   self.scope = scope
end
function TentativeSymbol.setmeta( obj )
  setmetatable( obj, { __index = TentativeSymbol  } )
end


local AnalyzingState = {}
AnalyzingState._val2NameMap = {}
function AnalyzingState:_getTxt( val )
   local name = self._val2NameMap[ val ]
   if name then
      return string.format( "AnalyzingState.%s", name )
   end
   return string.format( "illegal val -- %s", val )
end
function AnalyzingState._from( val )
   if AnalyzingState._val2NameMap[ val ] then
      return val
   end
   return nil
end
    
AnalyzingState.__allList = {}
function AnalyzingState.get__allList()
   return AnalyzingState.__allList
end

AnalyzingState.Other = 0
AnalyzingState._val2NameMap[0] = 'Other'
AnalyzingState.__allList[1] = AnalyzingState.Other
AnalyzingState.Constructor = 1
AnalyzingState._val2NameMap[1] = 'Constructor'
AnalyzingState.__allList[2] = AnalyzingState.Constructor
AnalyzingState.InitBlock = 2
AnalyzingState._val2NameMap[2] = 'InitBlock'
AnalyzingState.__allList[3] = AnalyzingState.InitBlock
AnalyzingState.ClassMethod = 3
AnalyzingState._val2NameMap[3] = 'ClassMethod'
AnalyzingState.__allList[4] = AnalyzingState.ClassMethod
AnalyzingState.Func = 4
AnalyzingState._val2NameMap[4] = 'Func'
AnalyzingState.__allList[5] = AnalyzingState.Func


local TransUnit = {}
_moduleObj.TransUnit = TransUnit
function TransUnit.new( moduleId, importModuleInfo, macroEval, analyzeModule, mode, pos, targetLuaVer, ctrl_info )
   local obj = {}
   TransUnit.setmeta( obj )
   if obj.__init then obj:__init( moduleId, importModuleInfo, macroEval, analyzeModule, mode, pos, targetLuaVer, ctrl_info ); end
   return obj
end
function TransUnit:__init(moduleId, importModuleInfo, macroEval, analyzeModule, mode, pos, targetLuaVer, ctrl_info) 
   self.protoClassMap = {}
   self.analyzingStateQueue = {}
   self.macroCallLineNo = 0
   self.useModuleMacroSet = {}
   self.ctrl_info = ctrl_info
   self.ignoreToCheckSymbol_ = false
   self.moduleId = moduleId
   self.helperInfo = Nodes.LuneHelperInfo.new(false, false, false, false, false, false, false)
   self.targetLuaVer = targetLuaVer
   self.importModuleInfo = importModuleInfo
   self.protoFuncMap = {}
   self.loopScopeQueue = {}
   self.has__func__Symbol = {}
   self.nodeManager = Nodes.NodeManager.new()
   self.importModuleName2ModuleInfo = {}
   self.importModule2ModuleInfoCurrent = {}
   self.importModule2ModuleInfo = {}
   self.macroScope = nil
   self.validMutControl = true
   self.moduleName = ""
   self.moduleType = Ast.headTypeInfo
   self.parser = Parser.DummyParser.new()
   self.subfileList = {}
   self.pushbackList = {}
   self.usedTokenList = {}
   self.globalScope = Ast.Scope.new(Ast.rootScope, false, nil)
   self.scope = Ast.Scope.new(self.globalScope, true, nil)
   self.topScope = self.scope
   self.moduleScope = self.scope
   self.tentativeSymbol = TentativeSymbol.new(nil, self.globalScope, false)
   self.typeId2ClassMap = {}
   self.typeInfo2ClassNode = {}
   self.currentToken = Parser.getEofToken(  )
   self.errMessList = {}
   self.warnMessList = {}
   self.macroEval = macroEval
   self.typeId2MacroInfo = {}
   self.macroMode = Nodes.MacroMode.None
   self.symbol2ValueMapForMacro = {}
   self.analyzeMode = _lune.unwrapDefault( mode, AnalyzeMode.Compile)
   self.analyzePos = _lune.unwrapDefault( pos, Parser.Position.new(0, 0))
   self.analyzeModule = _lune.unwrapDefault( analyzeModule, "")
   self.provideNode = nil
end
function TransUnit:pushAnalyzingState( state )

   table.insert( self.analyzingStateQueue, state )
end
function TransUnit:popAnalyzingState(  )

   if #self.analyzingStateQueue == 0 then
      self:error( "underflow analyzingStateQueue" )
   end
   
   table.remove( self.analyzingStateQueue )
end
function TransUnit:inAnalyzingState( state )

   if #self.analyzingStateQueue > 0 then
      return self.analyzingStateQueue[#self.analyzingStateQueue] == state
   end
   
   return false
end
function TransUnit:addErrMess( pos, mess )

   table.insert( self.errMessList, string.format( "%s:%d:%d: error: %s", self.parser:getStreamName(  ), pos.lineNo, pos.column, mess) )
end
function TransUnit:addWarnMess( pos, mess )

   table.insert( self.warnMessList, string.format( "%s:%d:%d: warning: %s", self.parser:getStreamName(  ), pos.lineNo, pos.column, mess) )
end
function TransUnit:pushScope( classFlag, baseInfo, interfaceList )

   self.scope = Ast.TypeInfo.createScope( self.scope, classFlag, baseInfo, interfaceList )
   return self.scope
end
function TransUnit:popScope(  )

   self.scope = self.scope:get_parent(  )
end
function TransUnit:prepareTentativeSymbol( scope, loopFlag )

   self.tentativeSymbol = TentativeSymbol.new(self.tentativeSymbol, scope, loopFlag)
end
function TransUnit:finishTentativeSymbol( complete )

   self.tentativeSymbol = _lune.unwrap( self.tentativeSymbol:finish( complete ))
end
function TransUnit:mergeTentativeSymbol( scope )

   self.tentativeSymbol:newSet( scope )
end
function TransUnit:getCurrentClass(  )

   local typeInfo = Ast.headTypeInfo
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
   until scope:isRoot(  )
   return typeInfo
end
function TransUnit:getCurrentNamespaceTypeInfo(  )

   return self.scope:getNamespaceTypeInfo(  )
end
function TransUnit:getCurrentNamespaceScope(  )

   return _lune.unwrap( self:getCurrentNamespaceTypeInfo(  ):get_scope())
end
function TransUnit:pushModule( externalFlag, name, mutable )

   local typeInfo = Ast.headTypeInfo
   local modName
   
   if name:find( "^@" ) then
      modName = name
   else
    
      modName = string.format( "@%s", name)
   end
   
   do
      local _exp = self.scope:getTypeInfoChild( modName )
      if _exp ~= nil then
         typeInfo = _exp
         self.scope = _lune.unwrap( Ast.getScope( typeInfo ))
      else
         local parentInfo = self:getCurrentNamespaceTypeInfo(  )
         local parentScope = self.scope
         local scope = self:pushScope( true )
         typeInfo = Ast.NormalTypeInfo.createModule( scope, parentInfo, externalFlag, modName, mutable )
         parentScope:addClass( modName, typeInfo )
      end
   end
   
   if not self.typeId2ClassMap[typeInfo:get_typeId(  )] then
      local namespace = Nodes.NamespaceInfo.new(modName, self.scope, typeInfo)
      self.typeId2ClassMap[typeInfo:get_typeId(  )] = namespace
   end
   
   return typeInfo
end
function TransUnit:popModule(  )

   self:popScope(  )
end
function TransUnit:pushClass( classFlag, abstractFlag, baseInfo, interfaceList, genTypeList, externalFlag, name, accessMode, defNamespace )

   local typeInfo = Ast.headTypeInfo
   do
      local _exp = self.scope:getTypeInfoChild( name )
      if _exp ~= nil then
         typeInfo = _exp
         if typeInfo:get_abstractFlag() ~= abstractFlag then
            self:addErrMess( self.currentToken.pos, "mismatch class abstract for prototpye" )
         end
         
         if typeInfo:get_accessMode() ~= accessMode then
            self:addErrMess( self.currentToken.pos, string.format( "mismatch class accessmode(%s) for prototpye accessmode(%s)", Ast.AccessMode:_getTxt( accessMode)
            , Ast.AccessMode:_getTxt( typeInfo:get_accessMode())
            ) )
         end
         
         if baseInfo ~= nil then
            if typeInfo:get_baseTypeInfo() ~= baseInfo then
               self:addErrMess( self.currentToken.pos, string.format( "mismatch class base class(%s) for prototpye base class(%s)", baseInfo:getTxt(  ), typeInfo:get_baseTypeInfo():getTxt(  )) )
            end
            
         end
         
         if interfaceList ~= nil then
            if #typeInfo:get_interfaceList() == #interfaceList then
               for index, ifType in pairs( typeInfo:get_interfaceList() ) do
                  if ifType ~= interfaceList[index] then
                     self:addErrMess( self.currentToken.pos, string.format( "mismatch class interface(%s) for prototpye interface(%s)", ifType:getTxt(  ), tostring( interfaceList[index])) )
                  end
                  
               end
               
            end
            
         end
         
         self.scope = _lune.unwrap( Ast.getScope( typeInfo ))
         do
            local _switchExp = (typeInfo:get_kind() )
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
         local parentScope = self.scope
         local scope = self:pushScope( true, baseInfo, interfaceList )
         typeInfo = Ast.NormalTypeInfo.createClass( classFlag, abstractFlag, scope, baseInfo, interfaceList, genTypeList, parentInfo, externalFlag, accessMode, name )
         parentScope:addClass( name, typeInfo )
      end
   end
   
   for __index, genType in pairs( genTypeList ) do
      self.scope:addAlternate( accessMode, genType:get_txt(), genType )
   end
   
   local namespace = defNamespace
   if  nil == namespace then
      local _namespace = namespace
   
      namespace = Nodes.NamespaceInfo.new(name, self.scope, typeInfo)
   end
   
   self.typeId2ClassMap[typeInfo:get_typeId(  )] = namespace
   return typeInfo
end
function TransUnit:popClass(  )

   self:popScope(  )
end
function TransUnit:addLocalVar( pos, argFlag, canBeLeft, name, typeInfo, mutable, allowShadow )

   if not allowShadow then
      if self.scope:getSymbolTypeInfo( name, self.scope, self.moduleScope ) then
         self:addErrMess( pos, string.format( "shadowing variable -- %s", name) )
      end
      
   end
   
   return self.scope:addLocalVar( argFlag, canBeLeft, name, typeInfo, mutable )
end
function TransUnit.setmeta( obj )
  setmetatable( obj, { __index = TransUnit  } )
end
function TransUnit:get_errMessList()
   return self.errMessList
end
function TransUnit:get_warnMessList()
   return self.warnMessList
end

local op2levelMap = {}
local op1levelMap = {}
local opTopLevel = 0
do
   local opLevelBase = 0
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
   regOpLevel( 2, {"|<<", "|>>"} )
   regOpLevel( 2, {".."} )
   regOpLevel( 2, {"+", "-"} )
   regOpLevel( 2, {"*", "/", "//", "%"} )
   regOpLevel( 1, {"`", ",,", ",,,", ",,,,"} )
   regOpLevel( 1, {"not", "#", "-", "~"} )
   regOpLevel( 1, {"^"} )
   opTopLevel = opLevelBase + 1
end

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
function TransUnit:createModifier( typeInfo, mutMode )

   if not self.validMutControl then
      return typeInfo
   end
   
   return Ast.NormalTypeInfo.createModifier( typeInfo, mutMode )
end

local _MetaInfo = {}
_moduleObj._MetaInfo = _MetaInfo
function _MetaInfo.setmeta( obj )
  setmetatable( obj, { __index = _MetaInfo  } )
end
function _MetaInfo.new( __formatVersion, __buildId, __typeId2ClassInfoMap, __typeInfoList, __varName2InfoMap, __funcName2InfoMap, __moduleTypeId, __moduleSymbolKind, __moduleMutable, __dependModuleMap, __dependIdMap, __macroName2InfoMap )
   local obj = {}
   _MetaInfo.setmeta( obj )
   if obj.__init then
      obj:__init( __formatVersion, __buildId, __typeId2ClassInfoMap, __typeInfoList, __varName2InfoMap, __funcName2InfoMap, __moduleTypeId, __moduleSymbolKind, __moduleMutable, __dependModuleMap, __dependIdMap, __macroName2InfoMap )
   end
   return obj
end
function _MetaInfo:__init( __formatVersion, __buildId, __typeId2ClassInfoMap, __typeInfoList, __varName2InfoMap, __funcName2InfoMap, __moduleTypeId, __moduleSymbolKind, __moduleMutable, __dependModuleMap, __dependIdMap, __macroName2InfoMap )

   self.__formatVersion = __formatVersion
   self.__buildId = __buildId
   self.__typeId2ClassInfoMap = __typeId2ClassInfoMap
   self.__typeInfoList = __typeInfoList
   self.__varName2InfoMap = __varName2InfoMap
   self.__funcName2InfoMap = __funcName2InfoMap
   self.__moduleTypeId = __moduleTypeId
   self.__moduleSymbolKind = __moduleSymbolKind
   self.__moduleMutable = __moduleMutable
   self.__dependModuleMap = __dependModuleMap
   self.__dependIdMap = __dependIdMap
   self.__macroName2InfoMap = __macroName2InfoMap
end

local MacroMetaArgInfo = {}
setmetatable( MacroMetaArgInfo, { ifList = {Mapping,} } )
function MacroMetaArgInfo.setmeta( obj )
  setmetatable( obj, { __index = MacroMetaArgInfo  } )
end
function MacroMetaArgInfo.new( name, typeId )
   local obj = {}
   MacroMetaArgInfo.setmeta( obj )
   if obj.__init then
      obj:__init( name, typeId )
   end
   return obj
end
function MacroMetaArgInfo:__init( name, typeId )

   self.name = name
   self.typeId = typeId
end
function MacroMetaArgInfo:_toMap()
  return self
end
function MacroMetaArgInfo._fromMap( val )
  local obj, mes = MacroMetaArgInfo._fromMapSub( {}, val )
  if obj then
     MacroMetaArgInfo.setmeta( obj )
  end
  return obj, mes
end
function MacroMetaArgInfo._fromStem( val )
  return MacroMetaArgInfo._fromMap( val )
end

function MacroMetaArgInfo._fromMapSub( obj, val )
   local memInfo = {}
   table.insert( memInfo, { name = "name", func = _lune._toStr, nilable = false, child = {} } )
   table.insert( memInfo, { name = "typeId", func = _lune._toInt, nilable = false, child = {} } )
   local result, mess = _lune._fromMap( obj, val, memInfo )
   if not result then
      return nil, mess
   end
   return obj
end

local MacroMetaInfo = {}
setmetatable( MacroMetaInfo, { ifList = {Mapping,} } )
function MacroMetaInfo.setmeta( obj )
  setmetatable( obj, { __index = MacroMetaInfo  } )
end
function MacroMetaInfo.new( name, argList, symList, stmtBlock, tokenList )
   local obj = {}
   MacroMetaInfo.setmeta( obj )
   if obj.__init then
      obj:__init( name, argList, symList, stmtBlock, tokenList )
   end
   return obj
end
function MacroMetaInfo:__init( name, argList, symList, stmtBlock, tokenList )

   self.name = name
   self.argList = argList
   self.symList = symList
   self.stmtBlock = stmtBlock
   self.tokenList = tokenList
end
function MacroMetaInfo:_toMap()
  return self
end
function MacroMetaInfo._fromMap( val )
  local obj, mes = MacroMetaInfo._fromMapSub( {}, val )
  if obj then
     MacroMetaInfo.setmeta( obj )
  end
  return obj, mes
end
function MacroMetaInfo._fromStem( val )
  return MacroMetaInfo._fromMap( val )
end

function MacroMetaInfo._fromMapSub( obj, val )
   local memInfo = {}
   table.insert( memInfo, { name = "name", func = _lune._toStr, nilable = false, child = {} } )
   table.insert( memInfo, { name = "argList", func = _lune._toList, nilable = false, child = { { func = MacroMetaArgInfo._fromMap, nilable = false, child = {} } } } )
   table.insert( memInfo, { name = "symList", func = _lune._toList, nilable = false, child = { { func = MacroMetaArgInfo._fromMap, nilable = false, child = {} } } } )
   table.insert( memInfo, { name = "stmtBlock", func = _lune._toStr, nilable = true, child = {} } )
   table.insert( memInfo, { name = "tokenList", func = _lune._toList, nilable = false, child = { { func = _lune._toList, nilable = false, child = { { func = _lune._toStem, nilable = false, child = {} } } } } } )
   local result, mess = _lune._fromMap( obj, val, memInfo )
   if not result then
      return nil, mess
   end
   return obj
end


local ImportParam = {}
function ImportParam.setmeta( obj )
  setmetatable( obj, { __index = ImportParam  } )
end
function ImportParam.new( transUnit, typeId2Scope, typeId2TypeInfo, metaInfo, scope, moduleTypeInfo, typeId2AtomMap )
   local obj = {}
   ImportParam.setmeta( obj )
   if obj.__init then
      obj:__init( transUnit, typeId2Scope, typeId2TypeInfo, metaInfo, scope, moduleTypeInfo, typeId2AtomMap )
   end
   return obj
end
function ImportParam:__init( transUnit, typeId2Scope, typeId2TypeInfo, metaInfo, scope, moduleTypeInfo, typeId2AtomMap )

   self.transUnit = transUnit
   self.typeId2Scope = typeId2Scope
   self.typeId2TypeInfo = typeId2TypeInfo
   self.metaInfo = metaInfo
   self.scope = scope
   self.moduleTypeInfo = moduleTypeInfo
   self.typeId2AtomMap = typeId2AtomMap
end

local _TypeInfo = {}
setmetatable( _TypeInfo, { ifList = {Mapping,} } )
function _TypeInfo.new(  )
   local obj = {}
   _TypeInfo.setmeta( obj )
   if obj.__init then obj:__init(  ); end
   return obj
end
function _TypeInfo:__init() 
   self.parentId = Ast.rootTypeId
   self.typeId = Ast.rootTypeId
   self.skind = Ast.SerializeKind.Normal
end
function _TypeInfo.setmeta( obj )
  setmetatable( obj, { __index = _TypeInfo  } )
end
function _TypeInfo:_toMap()
  return self
end
function _TypeInfo._fromMap( val )
  local obj, mes = _TypeInfo._fromMapSub( {}, val )
  if obj then
     _TypeInfo.setmeta( obj )
  end
  return obj, mes
end
function _TypeInfo._fromStem( val )
  return _TypeInfo._fromMap( val )
end

function _TypeInfo._fromMapSub( obj, val )
   local memInfo = {}
   table.insert( memInfo, { name = "skind", func = Ast.SerializeKind._from, nilable = false, child = {} } )
   table.insert( memInfo, { name = "parentId", func = _lune._toInt, nilable = false, child = {} } )
   table.insert( memInfo, { name = "typeId", func = _lune._toInt, nilable = false, child = {} } )
   local result, mess = _lune._fromMap( obj, val, memInfo )
   if not result then
      return nil, mess
   end
   return obj
end

function ImportParam:getTypeInfo( typeId )

   do
      local typeInfo = self.typeId2TypeInfo[typeId]
      if typeInfo ~= nil then
         return typeInfo, nil
      end
   end
   
   do
      local atom = self.typeId2AtomMap[typeId]
      if atom ~= nil then
         local typeInfo, mess = atom:createTypeInfo( self )
         if typeInfo ~= nil then
            self.typeId2TypeInfo[typeId] = typeInfo
         end
         
         return typeInfo, mess
      end
   end
   
   return nil, nil
end

local _TypeInfoNilable = {}
setmetatable( _TypeInfoNilable, { __index = _TypeInfo } )
function _TypeInfoNilable:createTypeInfo( param )

   local orgTypeInfo = _lune.unwrap( param:getTypeInfo( self.orgTypeId ))
   local newTypeInfo = orgTypeInfo:get_nilableTypeInfo(  )
   param.typeId2TypeInfo[self.typeId] = newTypeInfo
   return newTypeInfo, nil
end
function _TypeInfoNilable.setmeta( obj )
  setmetatable( obj, { __index = _TypeInfoNilable  } )
end
function _TypeInfoNilable.new( nilable, orgTypeId )
   local obj = {}
   _TypeInfoNilable.setmeta( obj )
   if obj.__init then
      obj:__init( nilable, orgTypeId )
   end
   return obj
end
function _TypeInfoNilable:__init( nilable, orgTypeId )

   _TypeInfo.__init( self)
   self.nilable = nilable
   self.orgTypeId = orgTypeId
end
function _TypeInfoNilable:_toMap()
  return self
end
function _TypeInfoNilable._fromMap( val )
  local obj, mes = _TypeInfoNilable._fromMapSub( {}, val )
  if obj then
     _TypeInfoNilable.setmeta( obj )
  end
  return obj, mes
end
function _TypeInfoNilable._fromStem( val )
  return _TypeInfoNilable._fromMap( val )
end

function _TypeInfoNilable._fromMapSub( obj, val )
   local result, mes = _TypeInfo._fromMapSub( obj, val )
   if not result then
      return nil, mes
   end

   local memInfo = {}
   table.insert( memInfo, { name = "nilable", func = _lune._toBool, nilable = false, child = {} } )
   table.insert( memInfo, { name = "orgTypeId", func = _lune._toInt, nilable = false, child = {} } )
   local result, mess = _lune._fromMap( obj, val, memInfo )
   if not result then
      return nil, mess
   end
   return obj
end

local _TypeInfoAlias = {}
setmetatable( _TypeInfoAlias, { __index = _TypeInfo } )
function _TypeInfoAlias:createTypeInfo( param )

   local srcTypeInfo = _lune.unwrap( param:getTypeInfo( self.srcTypeId ))
   local newTypeInfo = Ast.NormalTypeInfo.createAlias( self.rawTxt, true, Ast.AccessMode.Pub, param.moduleTypeInfo, srcTypeInfo )
   param.typeId2TypeInfo[self.typeId] = newTypeInfo
   local parentScope = param.typeId2Scope[self.parentId]
   if  nil == parentScope then
      local _parentScope = parentScope
   
      return nil, string.format( "not found parentScope %s %s", tostring( self.parentId), self.rawTxt)
   end
   
   parentScope:addAliasForType( self.rawTxt, newTypeInfo )
   return newTypeInfo, nil
end
function _TypeInfoAlias.setmeta( obj )
  setmetatable( obj, { __index = _TypeInfoAlias  } )
end
function _TypeInfoAlias.new( rawTxt, srcTypeId )
   local obj = {}
   _TypeInfoAlias.setmeta( obj )
   if obj.__init then
      obj:__init( rawTxt, srcTypeId )
   end
   return obj
end
function _TypeInfoAlias:__init( rawTxt, srcTypeId )

   _TypeInfo.__init( self)
   self.rawTxt = rawTxt
   self.srcTypeId = srcTypeId
end
function _TypeInfoAlias:_toMap()
  return self
end
function _TypeInfoAlias._fromMap( val )
  local obj, mes = _TypeInfoAlias._fromMapSub( {}, val )
  if obj then
     _TypeInfoAlias.setmeta( obj )
  end
  return obj, mes
end
function _TypeInfoAlias._fromStem( val )
  return _TypeInfoAlias._fromMap( val )
end

function _TypeInfoAlias._fromMapSub( obj, val )
   local result, mes = _TypeInfo._fromMapSub( obj, val )
   if not result then
      return nil, mes
   end

   local memInfo = {}
   table.insert( memInfo, { name = "rawTxt", func = _lune._toStr, nilable = false, child = {} } )
   table.insert( memInfo, { name = "srcTypeId", func = _lune._toInt, nilable = false, child = {} } )
   local result, mess = _lune._fromMap( obj, val, memInfo )
   if not result then
      return nil, mess
   end
   return obj
end

local _TypeInfoDDD = {}
setmetatable( _TypeInfoDDD, { __index = _TypeInfo } )
function _TypeInfoDDD:createTypeInfo( param )

   local itemTypeInfo = _lune.unwrap( param:getTypeInfo( self.itemTypeId ))
   local newTypeInfo = Ast.NormalTypeInfo.createDDD( itemTypeInfo, true )
   param.typeId2TypeInfo[self.typeId] = newTypeInfo
   return newTypeInfo, nil
end
function _TypeInfoDDD.setmeta( obj )
  setmetatable( obj, { __index = _TypeInfoDDD  } )
end
function _TypeInfoDDD.new( itemTypeId )
   local obj = {}
   _TypeInfoDDD.setmeta( obj )
   if obj.__init then
      obj:__init( itemTypeId )
   end
   return obj
end
function _TypeInfoDDD:__init( itemTypeId )

   _TypeInfo.__init( self)
   self.itemTypeId = itemTypeId
end
function _TypeInfoDDD:_toMap()
  return self
end
function _TypeInfoDDD._fromMap( val )
  local obj, mes = _TypeInfoDDD._fromMapSub( {}, val )
  if obj then
     _TypeInfoDDD.setmeta( obj )
  end
  return obj, mes
end
function _TypeInfoDDD._fromStem( val )
  return _TypeInfoDDD._fromMap( val )
end

function _TypeInfoDDD._fromMapSub( obj, val )
   local result, mes = _TypeInfo._fromMapSub( obj, val )
   if not result then
      return nil, mes
   end

   local memInfo = {}
   table.insert( memInfo, { name = "itemTypeId", func = _lune._toInt, nilable = false, child = {} } )
   local result, mess = _lune._fromMap( obj, val, memInfo )
   if not result then
      return nil, mess
   end
   return obj
end

local _TypeInfoAlternate = {}
setmetatable( _TypeInfoAlternate, { __index = _TypeInfo } )
function _TypeInfoAlternate:createTypeInfo( param )

   local baseInfo = _lune.unwrap( param:getTypeInfo( self.baseId ))
   local interfaceList = {}
   for __index, ifTypeId in pairs( self.ifList ) do
      table.insert( interfaceList, _lune.unwrap( param:getTypeInfo( ifTypeId )) )
   end
   
   local newTypeInfo = Ast.NormalTypeInfo.createAlternate( self.belongClassFlag, self.altIndex, self.txt, self.accessMode, param.moduleTypeInfo, baseInfo, interfaceList )
   param.typeId2TypeInfo[self.typeId] = newTypeInfo
   return newTypeInfo, nil
end
function _TypeInfoAlternate.setmeta( obj )
  setmetatable( obj, { __index = _TypeInfoAlternate  } )
end
function _TypeInfoAlternate.new( txt, accessMode, baseId, ifList, belongClassFlag, altIndex )
   local obj = {}
   _TypeInfoAlternate.setmeta( obj )
   if obj.__init then
      obj:__init( txt, accessMode, baseId, ifList, belongClassFlag, altIndex )
   end
   return obj
end
function _TypeInfoAlternate:__init( txt, accessMode, baseId, ifList, belongClassFlag, altIndex )

   _TypeInfo.__init( self)
   self.txt = txt
   self.accessMode = accessMode
   self.baseId = baseId
   self.ifList = ifList
   self.belongClassFlag = belongClassFlag
   self.altIndex = altIndex
end
function _TypeInfoAlternate:_toMap()
  return self
end
function _TypeInfoAlternate._fromMap( val )
  local obj, mes = _TypeInfoAlternate._fromMapSub( {}, val )
  if obj then
     _TypeInfoAlternate.setmeta( obj )
  end
  return obj, mes
end
function _TypeInfoAlternate._fromStem( val )
  return _TypeInfoAlternate._fromMap( val )
end

function _TypeInfoAlternate._fromMapSub( obj, val )
   local result, mes = _TypeInfo._fromMapSub( obj, val )
   if not result then
      return nil, mes
   end

   local memInfo = {}
   table.insert( memInfo, { name = "txt", func = _lune._toStr, nilable = false, child = {} } )
   table.insert( memInfo, { name = "accessMode", func = Ast.AccessMode._from, nilable = false, child = {} } )
   table.insert( memInfo, { name = "baseId", func = _lune._toInt, nilable = false, child = {} } )
   table.insert( memInfo, { name = "ifList", func = _lune._toList, nilable = false, child = { { func = _lune._toInt, nilable = false, child = {} } } } )
   table.insert( memInfo, { name = "belongClassFlag", func = _lune._toBool, nilable = false, child = {} } )
   table.insert( memInfo, { name = "altIndex", func = _lune._toInt, nilable = false, child = {} } )
   local result, mess = _lune._fromMap( obj, val, memInfo )
   if not result then
      return nil, mess
   end
   return obj
end

local _TypeInfoGeneric = {}
setmetatable( _TypeInfoGeneric, { __index = _TypeInfo } )
function _TypeInfoGeneric:createTypeInfo( param )

   local genSrcTypeInfo = _lune.unwrap( param:getTypeInfo( self.genSrcTypeId ))
   local genTypeList = {}
   for __index, typeId in pairs( self.genTypeList ) do
      table.insert( genTypeList, _lune.unwrap( param:getTypeInfo( typeId )) )
   end
   
   local newTypeInfo = Ast.NormalTypeInfo.createGeneric( genSrcTypeInfo, genTypeList, param.moduleTypeInfo )
   param.typeId2TypeInfo[self.typeId] = newTypeInfo
   return newTypeInfo, nil
end
function _TypeInfoGeneric.setmeta( obj )
  setmetatable( obj, { __index = _TypeInfoGeneric  } )
end
function _TypeInfoGeneric.new( genSrcTypeId, genTypeList )
   local obj = {}
   _TypeInfoGeneric.setmeta( obj )
   if obj.__init then
      obj:__init( genSrcTypeId, genTypeList )
   end
   return obj
end
function _TypeInfoGeneric:__init( genSrcTypeId, genTypeList )

   _TypeInfo.__init( self)
   self.genSrcTypeId = genSrcTypeId
   self.genTypeList = genTypeList
end
function _TypeInfoGeneric:_toMap()
  return self
end
function _TypeInfoGeneric._fromMap( val )
  local obj, mes = _TypeInfoGeneric._fromMapSub( {}, val )
  if obj then
     _TypeInfoGeneric.setmeta( obj )
  end
  return obj, mes
end
function _TypeInfoGeneric._fromStem( val )
  return _TypeInfoGeneric._fromMap( val )
end

function _TypeInfoGeneric._fromMapSub( obj, val )
   local result, mes = _TypeInfo._fromMapSub( obj, val )
   if not result then
      return nil, mes
   end

   local memInfo = {}
   table.insert( memInfo, { name = "genSrcTypeId", func = _lune._toInt, nilable = false, child = {} } )
   table.insert( memInfo, { name = "genTypeList", func = _lune._toList, nilable = false, child = { { func = _lune._toInt, nilable = false, child = {} } } } )
   local result, mess = _lune._fromMap( obj, val, memInfo )
   if not result then
      return nil, mess
   end
   return obj
end

local _TypeInfoBox = {}
setmetatable( _TypeInfoBox, { __index = _TypeInfo } )
function _TypeInfoBox:createTypeInfo( param )

   local boxingType = _lune.unwrap( param:getTypeInfo( self.boxingType ))
   local newTypeInfo = Ast.NormalTypeInfo.createBox( self.accessMode, boxingType )
   param.typeId2TypeInfo[self.typeId] = newTypeInfo
   return newTypeInfo, nil
end
function _TypeInfoBox.setmeta( obj )
  setmetatable( obj, { __index = _TypeInfoBox  } )
end
function _TypeInfoBox.new( accessMode, boxingType )
   local obj = {}
   _TypeInfoBox.setmeta( obj )
   if obj.__init then
      obj:__init( accessMode, boxingType )
   end
   return obj
end
function _TypeInfoBox:__init( accessMode, boxingType )

   _TypeInfo.__init( self)
   self.accessMode = accessMode
   self.boxingType = boxingType
end
function _TypeInfoBox:_toMap()
  return self
end
function _TypeInfoBox._fromMap( val )
  local obj, mes = _TypeInfoBox._fromMapSub( {}, val )
  if obj then
     _TypeInfoBox.setmeta( obj )
  end
  return obj, mes
end
function _TypeInfoBox._fromStem( val )
  return _TypeInfoBox._fromMap( val )
end

function _TypeInfoBox._fromMapSub( obj, val )
   local result, mes = _TypeInfo._fromMapSub( obj, val )
   if not result then
      return nil, mes
   end

   local memInfo = {}
   table.insert( memInfo, { name = "accessMode", func = Ast.AccessMode._from, nilable = false, child = {} } )
   table.insert( memInfo, { name = "boxingType", func = _lune._toInt, nilable = false, child = {} } )
   local result, mess = _lune._fromMap( obj, val, memInfo )
   if not result then
      return nil, mess
   end
   return obj
end

local _TypeInfoModifier = {}
setmetatable( _TypeInfoModifier, { __index = _TypeInfo } )
function _TypeInfoModifier:createTypeInfo( param )

   local srcTypeInfo = param:getTypeInfo( self.srcTypeId )
   if  nil == srcTypeInfo then
      local _srcTypeInfo = srcTypeInfo
   
      return nil, string.format( "not found srcType -- %d, %d", self.parentId, self.srcTypeId)
   end
   
   local newTypeInfo = param.transUnit:createModifier( srcTypeInfo, self.mutMode )
   param.typeId2TypeInfo[self.typeId] = newTypeInfo
   return newTypeInfo, nil
end
function _TypeInfoModifier.setmeta( obj )
  setmetatable( obj, { __index = _TypeInfoModifier  } )
end
function _TypeInfoModifier.new( srcTypeId, mutMode )
   local obj = {}
   _TypeInfoModifier.setmeta( obj )
   if obj.__init then
      obj:__init( srcTypeId, mutMode )
   end
   return obj
end
function _TypeInfoModifier:__init( srcTypeId, mutMode )

   _TypeInfo.__init( self)
   self.srcTypeId = srcTypeId
   self.mutMode = mutMode
end
function _TypeInfoModifier:_toMap()
  return self
end
function _TypeInfoModifier._fromMap( val )
  local obj, mes = _TypeInfoModifier._fromMapSub( {}, val )
  if obj then
     _TypeInfoModifier.setmeta( obj )
  end
  return obj, mes
end
function _TypeInfoModifier._fromStem( val )
  return _TypeInfoModifier._fromMap( val )
end

function _TypeInfoModifier._fromMapSub( obj, val )
   local result, mes = _TypeInfo._fromMapSub( obj, val )
   if not result then
      return nil, mes
   end

   local memInfo = {}
   table.insert( memInfo, { name = "srcTypeId", func = _lune._toInt, nilable = false, child = {} } )
   table.insert( memInfo, { name = "mutMode", func = Ast.MutMode._from, nilable = false, child = {} } )
   local result, mess = _lune._fromMap( obj, val, memInfo )
   if not result then
      return nil, mess
   end
   return obj
end

local _TypeInfoModule = {}
setmetatable( _TypeInfoModule, { __index = _TypeInfo } )
function _TypeInfoModule:createTypeInfo( param )

   local parentInfo = Ast.headTypeInfo
   if self.parentId ~= Ast.rootTypeId then
      local workTypeInfo = param:getTypeInfo( self.parentId )
      if  nil == workTypeInfo then
         local _workTypeInfo = workTypeInfo
      
         Util.err( string.format( "not found parentInfo %s %s", tostring( self.parentId), self.txt) )
      end
      
      parentInfo = workTypeInfo
   end
   
   local parentScope = param.typeId2Scope[self.parentId]
   if  nil == parentScope then
      local _parentScope = parentScope
   
      return nil, string.format( "not found parentScope %s %s", tostring( self.parentId), self.txt)
   end
   
   local newTypeInfo = parentScope:getTypeInfoChild( self.txt )
   do
      local _exp = newTypeInfo
      if _exp ~= nil then
         param.typeId2Scope[self.typeId] = Ast.getScope( _exp )
         if not _exp:get_scope() then
            return nil, string.format( "not found scope %s %s %s %s %s", tostring( parentScope), tostring( self.parentId), tostring( self.typeId), self.txt, _exp:getTxt(  ))
         end
         
         param.typeId2TypeInfo[self.typeId] = _exp
      else
         local scope = Ast.Scope.new(parentScope, true, nil)
         local mutable = false
         if self.typeId == param.metaInfo.__moduleTypeId then
            mutable = param.metaInfo.__moduleMutable
         end
         
         local workTypeInfo = Ast.NormalTypeInfo.createModule( scope, parentInfo, true, self.txt, mutable )
         newTypeInfo = workTypeInfo
         param.typeId2Scope[self.typeId] = scope
         param.typeId2TypeInfo[self.typeId] = workTypeInfo
         parentScope:addClass( self.txt, workTypeInfo )
      end
   end
   
   return newTypeInfo, nil
end
function _TypeInfoModule.setmeta( obj )
  setmetatable( obj, { __index = _TypeInfoModule  } )
end
function _TypeInfoModule.new( txt )
   local obj = {}
   _TypeInfoModule.setmeta( obj )
   if obj.__init then
      obj:__init( txt )
   end
   return obj
end
function _TypeInfoModule:__init( txt )

   _TypeInfo.__init( self)
   self.txt = txt
end
function _TypeInfoModule:_toMap()
  return self
end
function _TypeInfoModule._fromMap( val )
  local obj, mes = _TypeInfoModule._fromMapSub( {}, val )
  if obj then
     _TypeInfoModule.setmeta( obj )
  end
  return obj, mes
end
function _TypeInfoModule._fromStem( val )
  return _TypeInfoModule._fromMap( val )
end

function _TypeInfoModule._fromMapSub( obj, val )
   local result, mes = _TypeInfo._fromMapSub( obj, val )
   if not result then
      return nil, mes
   end

   local memInfo = {}
   table.insert( memInfo, { name = "txt", func = _lune._toStr, nilable = false, child = {} } )
   local result, mess = _lune._fromMap( obj, val, memInfo )
   if not result then
      return nil, mess
   end
   return obj
end

local _TypeInfoNormal = {}
setmetatable( _TypeInfoNormal, { __index = _TypeInfo } )
function _TypeInfoNormal:createTypeInfo( param )

   local newTypeInfo = nil
   if self.parentId ~= Ast.rootTypeId or not Ast.builtInTypeIdSet[self.typeId] or self.kind == Ast.TypeInfoKind.List or self.kind == Ast.TypeInfoKind.Array or self.kind == Ast.TypeInfoKind.Map or self.kind == Ast.TypeInfoKind.Set then
      local parentInfo = Ast.headTypeInfo
      if self.parentId ~= Ast.rootTypeId then
         local workTypeInfo = param:getTypeInfo( self.parentId )
         if  nil == workTypeInfo then
            local _workTypeInfo = workTypeInfo
         
            return nil, string.format( "not found parentInfo %s %s", tostring( self.parentId), self.txt)
         end
         
         parentInfo = workTypeInfo
      end
      
      local itemTypeInfo = {}
      for __index, typeId in pairs( self.itemTypeId ) do
         table.insert( itemTypeInfo, _lune.unwrap( param:getTypeInfo( typeId )) )
      end
      
      local argTypeInfo = {}
      for index, typeId in pairs( self.argTypeId ) do
         local argType, mess = param:getTypeInfo( typeId )
         if argType ~= nil then
            table.insert( argTypeInfo, argType )
         else
            local errmess = string.format( "not found arg (index:%d) -- %s.%s, %d, %d. %s", index, parentInfo:getTxt(  ), self.txt, typeId, #self.argTypeId, tostring( mess))
            return nil, errmess
         end
         
      end
      
      local retTypeInfo = {}
      for __index, typeId in pairs( self.retTypeId ) do
         table.insert( retTypeInfo, _lune.unwrap( param:getTypeInfo( typeId )) )
      end
      
      local baseInfo = _lune.unwrap( param:getTypeInfo( self.baseId ))
      local interfaceList = {}
      for __index, ifTypeId in pairs( self.ifList ) do
         table.insert( interfaceList, _lune.unwrap( param:getTypeInfo( ifTypeId )) )
      end
      
      local parentScope = param.typeId2Scope[self.parentId]
      if  nil == parentScope then
         local _parentScope = parentScope
      
         return nil, string.format( "not found parentScope %s %s", tostring( self.parentId), self.txt)
      end
      
      if self.txt ~= "" then
         newTypeInfo = parentScope:getTypeInfoChild( self.txt )
      end
      
      if newTypeInfo and (self.kind == Ast.TypeInfoKind.Class or self.kind == Ast.TypeInfoKind.IF ) then
         do
            local _exp = newTypeInfo
            if _exp ~= nil then
               param.typeId2Scope[self.typeId] = Ast.getScope( _exp )
               if not _exp:get_scope() then
                  Util.err( string.format( "not found scope %s %s %s %s %s", tostring( parentScope), tostring( self.parentId), tostring( self.typeId), self.txt, _exp:getTxt(  )) )
               end
               
               param.typeId2TypeInfo[self.typeId] = _exp
            end
         end
         
         
      else
       
         if self.kind == Ast.TypeInfoKind.Class or self.kind == Ast.TypeInfoKind.IF then
            local baseScope = _lune.unwrap( param.typeId2Scope[self.baseId])
            local scope = Ast.Scope.new(parentScope, true, baseScope)
            local altTypeList = {}
            for __index, itemType in pairs( itemTypeInfo ) do
               table.insert( altTypeList, _lune.unwrap( (_lune.__Cast( itemType, 3, Ast.AlternateTypeInfo ) )) )
            end
            
            local workTypeInfo = Ast.NormalTypeInfo.createClass( self.kind == Ast.TypeInfoKind.Class, self.abstractFlag, scope, baseInfo, interfaceList, altTypeList, parentInfo, true, Ast.AccessMode.Pub, self.txt )
            newTypeInfo = workTypeInfo
            param.typeId2Scope[self.typeId] = scope
            param.typeId2TypeInfo[self.typeId] = workTypeInfo
            parentScope:addClass( self.txt, workTypeInfo )
         else
          
            local scope = nil
            if self.kind == Ast.TypeInfoKind.Func or self.kind == Ast.TypeInfoKind.Method then
               scope = Ast.Scope.new(parentScope, false, nil)
            end
            
            local typeInfoKind = self.kind
            local accessMode = self.accessMode
            local workTypeInfo = Ast.NormalTypeInfo.create( accessMode, self.abstractFlag, scope, baseInfo, interfaceList, parentInfo, self.staticFlag, typeInfoKind, self.txt, itemTypeInfo, argTypeInfo, retTypeInfo, self.mutMode )
            newTypeInfo = workTypeInfo
            param.typeId2TypeInfo[self.typeId] = workTypeInfo
            do
               local _switchExp = self.kind
               if _switchExp == Ast.TypeInfoKind.Func or _switchExp == Ast.TypeInfoKind.Method or _switchExp == Ast.TypeInfoKind.Macro or _switchExp == Ast.TypeInfoKind.Form or _switchExp == Ast.TypeInfoKind.FormFunc then
                  local symbolKind = Ast.SymbolKind.Fun
                  do
                     local _switchExp = self.kind
                     if _switchExp == Ast.TypeInfoKind.Method then
                        symbolKind = Ast.SymbolKind.Mtd
                     elseif _switchExp == Ast.TypeInfoKind.Macro then
                        symbolKind = Ast.SymbolKind.Mac
                     elseif _switchExp == Ast.TypeInfoKind.Form or _switchExp == Ast.TypeInfoKind.FormFunc then
                        symbolKind = Ast.SymbolKind.Typ
                     end
                  end
                  
                  local workParentScope = _lune.unwrap( param.typeId2Scope[self.parentId])
                  workParentScope:add( symbolKind, false, self.kind == Ast.TypeInfoKind.Func, self.txt, workTypeInfo, accessMode, self.staticFlag, Ast.MutMode.IMut, true )
                  param.typeId2Scope[self.typeId] = scope
               end
            end
            
         end
         
      end
      
   else
    
      newTypeInfo = param.scope:getTypeInfo( self.txt, param.scope, false )
      if not newTypeInfo then
         for key, val in pairs( self:_toMap(  ) ) do
            Util.errorLog( string.format( "error: illegal self %s:%s", key, tostring( val)) )
         end
         
      end
      
      param.typeId2TypeInfo[self.typeId] = _lune.unwrap( newTypeInfo)
   end
   
   return newTypeInfo, nil
end
function _TypeInfoNormal.setmeta( obj )
  setmetatable( obj, { __index = _TypeInfoNormal  } )
end
function _TypeInfoNormal.new( abstractFlag, baseId, txt, staticFlag, accessMode, kind, mutMode, ifList, itemTypeId, argTypeId, retTypeId, children )
   local obj = {}
   _TypeInfoNormal.setmeta( obj )
   if obj.__init then
      obj:__init( abstractFlag, baseId, txt, staticFlag, accessMode, kind, mutMode, ifList, itemTypeId, argTypeId, retTypeId, children )
   end
   return obj
end
function _TypeInfoNormal:__init( abstractFlag, baseId, txt, staticFlag, accessMode, kind, mutMode, ifList, itemTypeId, argTypeId, retTypeId, children )

   _TypeInfo.__init( self)
   self.abstractFlag = abstractFlag
   self.baseId = baseId
   self.txt = txt
   self.staticFlag = staticFlag
   self.accessMode = accessMode
   self.kind = kind
   self.mutMode = mutMode
   self.ifList = ifList
   self.itemTypeId = itemTypeId
   self.argTypeId = argTypeId
   self.retTypeId = retTypeId
   self.children = children
end
function _TypeInfoNormal:_toMap()
  return self
end
function _TypeInfoNormal._fromMap( val )
  local obj, mes = _TypeInfoNormal._fromMapSub( {}, val )
  if obj then
     _TypeInfoNormal.setmeta( obj )
  end
  return obj, mes
end
function _TypeInfoNormal._fromStem( val )
  return _TypeInfoNormal._fromMap( val )
end

function _TypeInfoNormal._fromMapSub( obj, val )
   local result, mes = _TypeInfo._fromMapSub( obj, val )
   if not result then
      return nil, mes
   end

   local memInfo = {}
   table.insert( memInfo, { name = "abstractFlag", func = _lune._toBool, nilable = false, child = {} } )
   table.insert( memInfo, { name = "baseId", func = _lune._toInt, nilable = false, child = {} } )
   table.insert( memInfo, { name = "txt", func = _lune._toStr, nilable = false, child = {} } )
   table.insert( memInfo, { name = "staticFlag", func = _lune._toBool, nilable = false, child = {} } )
   table.insert( memInfo, { name = "accessMode", func = Ast.AccessMode._from, nilable = false, child = {} } )
   table.insert( memInfo, { name = "kind", func = Ast.TypeInfoKind._from, nilable = false, child = {} } )
   table.insert( memInfo, { name = "mutMode", func = Ast.MutMode._from, nilable = false, child = {} } )
   table.insert( memInfo, { name = "ifList", func = _lune._toList, nilable = false, child = { { func = _lune._toInt, nilable = false, child = {} } } } )
   table.insert( memInfo, { name = "itemTypeId", func = _lune._toList, nilable = false, child = { { func = _lune._toInt, nilable = false, child = {} } } } )
   table.insert( memInfo, { name = "argTypeId", func = _lune._toList, nilable = false, child = { { func = _lune._toInt, nilable = false, child = {} } } } )
   table.insert( memInfo, { name = "retTypeId", func = _lune._toList, nilable = false, child = { { func = _lune._toInt, nilable = false, child = {} } } } )
   table.insert( memInfo, { name = "children", func = _lune._toList, nilable = false, child = { { func = _lune._toInt, nilable = false, child = {} } } } )
   local result, mess = _lune._fromMap( obj, val, memInfo )
   if not result then
      return nil, mess
   end
   return obj
end

local _TypeInfoEnum = {}
setmetatable( _TypeInfoEnum, { __index = _TypeInfo } )
function _TypeInfoEnum:createTypeInfo( param )

   local accessMode = _lune.unwrap( Ast.AccessMode._from( self.accessMode ))
   local parentInfo = _lune.unwrap( param:getTypeInfo( self.parentId ))
   local name2EnumValInfo = {}
   local parentScope = _lune.unwrap( Ast.getScope( parentInfo ))
   local scope = Ast.Scope.new(parentScope, true, nil)
   param.typeId2Scope[self.typeId] = scope
   local valTypeInfo = _lune.unwrap( param:getTypeInfo( self.valTypeId ))
   local enumTypeInfo = Ast.NormalTypeInfo.createEnum( scope, parentInfo, true, accessMode, self.txt, valTypeInfo )
   local newTypeInfo = enumTypeInfo
   param.typeId2TypeInfo[self.typeId] = enumTypeInfo
   local function getEnumLiteral( val )
   
      do
         local _switchExp = valTypeInfo
         if _switchExp == Ast.builtinTypeInt then
            return _lune.newAlge( Ast.EnumLiteral.Int, {math.floor(val)})
         elseif _switchExp == Ast.builtinTypeReal then
            return _lune.newAlge( Ast.EnumLiteral.Real, {val * 1.0})
         elseif _switchExp == Ast.builtinTypeString then
            return _lune.newAlge( Ast.EnumLiteral.Str, {val})
         end
      end
      
      return nil
   end
   
   for valName, valData in pairs( self.enumValList ) do
      local val = getEnumLiteral( valData )
      if  nil == val then
         local _val = val
      
         return nil, string.format( "unknown enum val type -- %s", valTypeInfo:getTxt(  ))
      end
      
      enumTypeInfo:addEnumValInfo( Ast.EnumValInfo.new(valName, val) )
      scope:addEnumVal( valName, enumTypeInfo )
   end
   
   parentScope:addEnum( accessMode, self.txt, enumTypeInfo )
   return newTypeInfo, nil
end
function _TypeInfoEnum.setmeta( obj )
  setmetatable( obj, { __index = _TypeInfoEnum  } )
end
function _TypeInfoEnum.new( txt, accessMode, valTypeId, enumValList )
   local obj = {}
   _TypeInfoEnum.setmeta( obj )
   if obj.__init then
      obj:__init( txt, accessMode, valTypeId, enumValList )
   end
   return obj
end
function _TypeInfoEnum:__init( txt, accessMode, valTypeId, enumValList )

   _TypeInfo.__init( self)
   self.txt = txt
   self.accessMode = accessMode
   self.valTypeId = valTypeId
   self.enumValList = enumValList
end
function _TypeInfoEnum:_toMap()
  return self
end
function _TypeInfoEnum._fromMap( val )
  local obj, mes = _TypeInfoEnum._fromMapSub( {}, val )
  if obj then
     _TypeInfoEnum.setmeta( obj )
  end
  return obj, mes
end
function _TypeInfoEnum._fromStem( val )
  return _TypeInfoEnum._fromMap( val )
end

function _TypeInfoEnum._fromMapSub( obj, val )
   local result, mes = _TypeInfo._fromMapSub( obj, val )
   if not result then
      return nil, mes
   end

   local memInfo = {}
   table.insert( memInfo, { name = "txt", func = _lune._toStr, nilable = false, child = {} } )
   table.insert( memInfo, { name = "accessMode", func = Ast.AccessMode._from, nilable = false, child = {} } )
   table.insert( memInfo, { name = "valTypeId", func = _lune._toInt, nilable = false, child = {} } )
   table.insert( memInfo, { name = "enumValList", func = _lune._toMap, nilable = false, child = { { func = _lune._toStr, nilable = false, child = {} }, 
{ func = _lune._toStem, nilable = false, child = {} } } } )
   local result, mess = _lune._fromMap( obj, val, memInfo )
   if not result then
      return nil, mess
   end
   return obj
end

local _TypeInfoAlgeVal = {}
setmetatable( _TypeInfoAlgeVal, { ifList = {Mapping,} } )
function _TypeInfoAlgeVal.setmeta( obj )
  setmetatable( obj, { __index = _TypeInfoAlgeVal  } )
end
function _TypeInfoAlgeVal.new( name, typeList )
   local obj = {}
   _TypeInfoAlgeVal.setmeta( obj )
   if obj.__init then
      obj:__init( name, typeList )
   end
   return obj
end
function _TypeInfoAlgeVal:__init( name, typeList )

   self.name = name
   self.typeList = typeList
end
function _TypeInfoAlgeVal:_toMap()
  return self
end
function _TypeInfoAlgeVal._fromMap( val )
  local obj, mes = _TypeInfoAlgeVal._fromMapSub( {}, val )
  if obj then
     _TypeInfoAlgeVal.setmeta( obj )
  end
  return obj, mes
end
function _TypeInfoAlgeVal._fromStem( val )
  return _TypeInfoAlgeVal._fromMap( val )
end

function _TypeInfoAlgeVal._fromMapSub( obj, val )
   local memInfo = {}
   table.insert( memInfo, { name = "name", func = _lune._toStr, nilable = false, child = {} } )
   table.insert( memInfo, { name = "typeList", func = _lune._toList, nilable = false, child = { { func = _lune._toInt, nilable = false, child = {} } } } )
   local result, mess = _lune._fromMap( obj, val, memInfo )
   if not result then
      return nil, mess
   end
   return obj
end

local _TypeInfoAlge = {}
setmetatable( _TypeInfoAlge, { __index = _TypeInfo } )
function _TypeInfoAlge:createTypeInfo( param )

   local accessMode = _lune.unwrap( Ast.AccessMode._from( self.accessMode ))
   local parentInfo = _lune.unwrap( param:getTypeInfo( self.parentId ))
   local name2AlgeValInfo = {}
   local parentScope = _lune.unwrap( Ast.getScope( parentInfo ))
   local scope = Ast.Scope.new(parentScope, true, nil)
   param.typeId2Scope[self.typeId] = scope
   local algeTypeInfo = Ast.NormalTypeInfo.createAlge( scope, parentInfo, true, accessMode, self.txt )
   local newTypeInfo = algeTypeInfo
   param.typeId2TypeInfo[self.typeId] = algeTypeInfo
   for __index, valInfo in pairs( self.algeValList ) do
      local typeInfoList = {}
      for __index, orgTypeId in pairs( valInfo.typeList ) do
         table.insert( typeInfoList, _lune.unwrap( param:getTypeInfo( orgTypeId )) )
      end
      
      local algeVal = Ast.AlgeValInfo.new(valInfo.name, typeInfoList)
      scope:addAlgeVal( valInfo.name, algeTypeInfo )
      algeTypeInfo:addValInfo( algeVal )
   end
   
   parentScope:addAlge( accessMode, self.txt, algeTypeInfo )
   return newTypeInfo, nil
end
function _TypeInfoAlge.setmeta( obj )
  setmetatable( obj, { __index = _TypeInfoAlge  } )
end
function _TypeInfoAlge.new( txt, accessMode, algeValList )
   local obj = {}
   _TypeInfoAlge.setmeta( obj )
   if obj.__init then
      obj:__init( txt, accessMode, algeValList )
   end
   return obj
end
function _TypeInfoAlge:__init( txt, accessMode, algeValList )

   _TypeInfo.__init( self)
   self.txt = txt
   self.accessMode = accessMode
   self.algeValList = algeValList
end
function _TypeInfoAlge:_toMap()
  return self
end
function _TypeInfoAlge._fromMap( val )
  local obj, mes = _TypeInfoAlge._fromMapSub( {}, val )
  if obj then
     _TypeInfoAlge.setmeta( obj )
  end
  return obj, mes
end
function _TypeInfoAlge._fromStem( val )
  return _TypeInfoAlge._fromMap( val )
end

function _TypeInfoAlge._fromMapSub( obj, val )
   local result, mes = _TypeInfo._fromMapSub( obj, val )
   if not result then
      return nil, mes
   end

   local memInfo = {}
   table.insert( memInfo, { name = "txt", func = _lune._toStr, nilable = false, child = {} } )
   table.insert( memInfo, { name = "accessMode", func = Ast.AccessMode._from, nilable = false, child = {} } )
   table.insert( memInfo, { name = "algeValList", func = _lune._toList, nilable = false, child = { { func = _TypeInfoAlgeVal._fromMap, nilable = false, child = {} } } } )
   local result, mess = _lune._fromMap( obj, val, memInfo )
   if not result then
      return nil, mess
   end
   return obj
end


local BuiltinFuncType = {}
_moduleObj.BuiltinFuncType = BuiltinFuncType
function BuiltinFuncType.new(  )
   local obj = {}
   BuiltinFuncType.setmeta( obj )
   if obj.__init then obj:__init(  ); end
   return obj
end
function BuiltinFuncType:__init() 
   self.lune__fcall = Ast.headTypeInfo
   self.lune__kind = Ast.headTypeInfo
   self.lune__load = Ast.headTypeInfo
   self.lune_collectgarbage = Ast.headTypeInfo
   self.lune_error = Ast.headTypeInfo
   self.lune_load = Ast.headTypeInfo
   self.lune_loadfile = Ast.headTypeInfo
   self.lune_print = Ast.headTypeInfo
   self.lune_require = Ast.headTypeInfo
   self.lune_tonumber = Ast.headTypeInfo
   self.lune_tostring = Ast.headTypeInfo
   self.lune_type = Ast.headTypeInfo
   self.istream___attrib = Ast.headTypeInfo
   self.istream_close = Ast.headTypeInfo
   self.istream_read = Ast.headTypeInfo
   self.ostream___attrib = Ast.headTypeInfo
   self.ostream_close = Ast.headTypeInfo
   self.ostream_flush = Ast.headTypeInfo
   self.ostream_write = Ast.headTypeInfo
   self.luastream___attrib = Ast.headTypeInfo
   self.luastream_close = Ast.headTypeInfo
   self.luastream_flush = Ast.headTypeInfo
   self.luastream_read = Ast.headTypeInfo
   self.luastream_seek = Ast.headTypeInfo
   self.luastream_write = Ast.headTypeInfo
   self.mapping___attrib = Ast.headTypeInfo
   self.mapping__toMap = Ast.headTypeInfo
   self.io_open = Ast.headTypeInfo
   self.io_popen = Ast.headTypeInfo
   self.io_stderr = Ast.headTypeInfo
   self.io_stdin = Ast.headTypeInfo
   self.io_stdout = Ast.headTypeInfo
   self.package_path = Ast.headTypeInfo
   self.package_searchpath = Ast.headTypeInfo
   self.os_clock = Ast.headTypeInfo
   self.os_date = Ast.headTypeInfo
   self.os_difftime = Ast.headTypeInfo
   self.os_exit = Ast.headTypeInfo
   self.os_remove = Ast.headTypeInfo
   self.os_rename = Ast.headTypeInfo
   self.os_time = Ast.headTypeInfo
   self.string_byte = Ast.headTypeInfo
   self.string_dump = Ast.headTypeInfo
   self.string_find = Ast.headTypeInfo
   self.string_format = Ast.headTypeInfo
   self.string_gmatch = Ast.headTypeInfo
   self.string_gsub = Ast.headTypeInfo
   self.string_lower = Ast.headTypeInfo
   self.string_rep = Ast.headTypeInfo
   self.string_reverse = Ast.headTypeInfo
   self.string_sub = Ast.headTypeInfo
   self.string_upper = Ast.headTypeInfo
   self.str_byte = Ast.headTypeInfo
   self.str_find = Ast.headTypeInfo
   self.str_format = Ast.headTypeInfo
   self.str_gmatch = Ast.headTypeInfo
   self.str_gsub = Ast.headTypeInfo
   self.str_lower = Ast.headTypeInfo
   self.str_rep = Ast.headTypeInfo
   self.str_reverse = Ast.headTypeInfo
   self.str_sub = Ast.headTypeInfo
   self.str_upper = Ast.headTypeInfo
   self.list_insert = Ast.headTypeInfo
   self.list_remove = Ast.headTypeInfo
   self.list_sort = Ast.headTypeInfo
   self.list_unpack = Ast.headTypeInfo
   self.array_sort = Ast.headTypeInfo
   self.array_unpack = Ast.headTypeInfo
   self.set_add = Ast.headTypeInfo
   self.set_and = Ast.headTypeInfo
   self.set_clone = Ast.headTypeInfo
   self.set_del = Ast.headTypeInfo
   self.set_has = Ast.headTypeInfo
   self.set_len = Ast.headTypeInfo
   self.set_or = Ast.headTypeInfo
   self.set_sub = Ast.headTypeInfo
   self.math_random = Ast.headTypeInfo
   self.math_randomseed = Ast.headTypeInfo
   self.debug_getinfo = Ast.headTypeInfo
   self.debug_getlocal = Ast.headTypeInfo
   self.nilable_val = Ast.headTypeInfo
   
end
function BuiltinFuncType.setmeta( obj )
  setmetatable( obj, { __index = BuiltinFuncType  } )
end

local builtinFunc = BuiltinFuncType.new()
local function getBuiltinFunc(  )

   return builtinFunc
end
_moduleObj.getBuiltinFunc = getBuiltinFunc
local function setupBuiltinTypeInfo( name, fieldName, typeInfo )

   local function process_(  )
   
      do
         local _switchExp = fieldName
         if _switchExp == '_fcall' then
            builtinFunc.lune__fcall = typeInfo
         elseif _switchExp == '_kind' then
            builtinFunc.lune__kind = typeInfo
         elseif _switchExp == '_load' then
            builtinFunc.lune__load = typeInfo
         elseif _switchExp == 'collectgarbage' then
            builtinFunc.lune_collectgarbage = typeInfo
         elseif _switchExp == 'error' then
            builtinFunc.lune_error = typeInfo
         elseif _switchExp == 'load' then
            builtinFunc.lune_load = typeInfo
         elseif _switchExp == 'loadfile' then
            builtinFunc.lune_loadfile = typeInfo
         elseif _switchExp == 'print' then
            builtinFunc.lune_print = typeInfo
         elseif _switchExp == 'require' then
            builtinFunc.lune_require = typeInfo
         elseif _switchExp == 'tonumber' then
            builtinFunc.lune_tonumber = typeInfo
         elseif _switchExp == 'tostring' then
            builtinFunc.lune_tostring = typeInfo
         elseif _switchExp == 'type' then
            builtinFunc.lune_type = typeInfo
         end
      end
      
   end
   
   local function process_iStream(  )
   
      do
         local _switchExp = fieldName
         if _switchExp == '__attrib' then
            builtinFunc.istream___attrib = typeInfo
         elseif _switchExp == 'close' then
            builtinFunc.istream_close = typeInfo
         elseif _switchExp == 'read' then
            builtinFunc.istream_read = typeInfo
         end
      end
      
   end
   
   local function process_oStream(  )
   
      do
         local _switchExp = fieldName
         if _switchExp == '__attrib' then
            builtinFunc.ostream___attrib = typeInfo
         elseif _switchExp == 'close' then
            builtinFunc.ostream_close = typeInfo
         elseif _switchExp == 'flush' then
            builtinFunc.ostream_flush = typeInfo
         elseif _switchExp == 'write' then
            builtinFunc.ostream_write = typeInfo
         end
      end
      
   end
   
   local function process_luaStream(  )
   
      do
         local _switchExp = fieldName
         if _switchExp == '__attrib' then
            builtinFunc.luastream___attrib = typeInfo
         elseif _switchExp == 'close' then
            builtinFunc.luastream_close = typeInfo
         elseif _switchExp == 'flush' then
            builtinFunc.luastream_flush = typeInfo
         elseif _switchExp == 'read' then
            builtinFunc.luastream_read = typeInfo
         elseif _switchExp == 'seek' then
            builtinFunc.luastream_seek = typeInfo
         elseif _switchExp == 'write' then
            builtinFunc.luastream_write = typeInfo
         end
      end
      
   end
   
   local function process_Mapping(  )
   
      do
         local _switchExp = fieldName
         if _switchExp == '__attrib' then
            builtinFunc.mapping___attrib = typeInfo
         elseif _switchExp == '_toMap' then
            builtinFunc.mapping__toMap = typeInfo
         end
      end
      
   end
   
   local function process_io(  )
   
      do
         local _switchExp = fieldName
         if _switchExp == 'open' then
            builtinFunc.io_open = typeInfo
         elseif _switchExp == 'popen' then
            builtinFunc.io_popen = typeInfo
         elseif _switchExp == 'stderr' then
            builtinFunc.io_stderr = typeInfo
         elseif _switchExp == 'stdin' then
            builtinFunc.io_stdin = typeInfo
         elseif _switchExp == 'stdout' then
            builtinFunc.io_stdout = typeInfo
         end
      end
      
   end
   
   local function process_package(  )
   
      do
         local _switchExp = fieldName
         if _switchExp == 'path' then
            builtinFunc.package_path = typeInfo
         elseif _switchExp == 'searchpath' then
            builtinFunc.package_searchpath = typeInfo
         end
      end
      
   end
   
   local function process_os(  )
   
      do
         local _switchExp = fieldName
         if _switchExp == 'clock' then
            builtinFunc.os_clock = typeInfo
         elseif _switchExp == 'date' then
            builtinFunc.os_date = typeInfo
         elseif _switchExp == 'difftime' then
            builtinFunc.os_difftime = typeInfo
         elseif _switchExp == 'exit' then
            builtinFunc.os_exit = typeInfo
         elseif _switchExp == 'remove' then
            builtinFunc.os_remove = typeInfo
         elseif _switchExp == 'rename' then
            builtinFunc.os_rename = typeInfo
         elseif _switchExp == 'time' then
            builtinFunc.os_time = typeInfo
         end
      end
      
   end
   
   local function process_string(  )
   
      do
         local _switchExp = fieldName
         if _switchExp == 'byte' then
            builtinFunc.string_byte = typeInfo
         elseif _switchExp == 'dump' then
            builtinFunc.string_dump = typeInfo
         elseif _switchExp == 'find' then
            builtinFunc.string_find = typeInfo
         elseif _switchExp == 'format' then
            builtinFunc.string_format = typeInfo
         elseif _switchExp == 'gmatch' then
            builtinFunc.string_gmatch = typeInfo
         elseif _switchExp == 'gsub' then
            builtinFunc.string_gsub = typeInfo
         elseif _switchExp == 'lower' then
            builtinFunc.string_lower = typeInfo
         elseif _switchExp == 'rep' then
            builtinFunc.string_rep = typeInfo
         elseif _switchExp == 'reverse' then
            builtinFunc.string_reverse = typeInfo
         elseif _switchExp == 'sub' then
            builtinFunc.string_sub = typeInfo
         elseif _switchExp == 'upper' then
            builtinFunc.string_upper = typeInfo
         end
      end
      
   end
   
   local function process_str(  )
   
      do
         local _switchExp = fieldName
         if _switchExp == 'byte' then
            builtinFunc.str_byte = typeInfo
         elseif _switchExp == 'find' then
            builtinFunc.str_find = typeInfo
         elseif _switchExp == 'format' then
            builtinFunc.str_format = typeInfo
         elseif _switchExp == 'gmatch' then
            builtinFunc.str_gmatch = typeInfo
         elseif _switchExp == 'gsub' then
            builtinFunc.str_gsub = typeInfo
         elseif _switchExp == 'lower' then
            builtinFunc.str_lower = typeInfo
         elseif _switchExp == 'rep' then
            builtinFunc.str_rep = typeInfo
         elseif _switchExp == 'reverse' then
            builtinFunc.str_reverse = typeInfo
         elseif _switchExp == 'sub' then
            builtinFunc.str_sub = typeInfo
         elseif _switchExp == 'upper' then
            builtinFunc.str_upper = typeInfo
         end
      end
      
   end
   
   local function process_List(  )
   
      do
         local _switchExp = fieldName
         if _switchExp == 'insert' then
            builtinFunc.list_insert = typeInfo
         elseif _switchExp == 'remove' then
            builtinFunc.list_remove = typeInfo
         elseif _switchExp == 'sort' then
            builtinFunc.list_sort = typeInfo
         elseif _switchExp == 'unpack' then
            builtinFunc.list_unpack = typeInfo
         end
      end
      
   end
   
   local function process_Array(  )
   
      do
         local _switchExp = fieldName
         if _switchExp == 'sort' then
            builtinFunc.array_sort = typeInfo
         elseif _switchExp == 'unpack' then
            builtinFunc.array_unpack = typeInfo
         end
      end
      
   end
   
   local function process_Set(  )
   
      do
         local _switchExp = fieldName
         if _switchExp == 'add' then
            builtinFunc.set_add = typeInfo
         elseif _switchExp == 'and' then
            builtinFunc.set_and = typeInfo
         elseif _switchExp == 'clone' then
            builtinFunc.set_clone = typeInfo
         elseif _switchExp == 'del' then
            builtinFunc.set_del = typeInfo
         elseif _switchExp == 'has' then
            builtinFunc.set_has = typeInfo
         elseif _switchExp == 'len' then
            builtinFunc.set_len = typeInfo
         elseif _switchExp == 'or' then
            builtinFunc.set_or = typeInfo
         elseif _switchExp == 'sub' then
            builtinFunc.set_sub = typeInfo
         end
      end
      
   end
   
   local function process_math(  )
   
      do
         local _switchExp = fieldName
         if _switchExp == 'random' then
            builtinFunc.math_random = typeInfo
         elseif _switchExp == 'randomseed' then
            builtinFunc.math_randomseed = typeInfo
         end
      end
      
   end
   
   local function process_debug(  )
   
      do
         local _switchExp = fieldName
         if _switchExp == 'getinfo' then
            builtinFunc.debug_getinfo = typeInfo
         elseif _switchExp == 'getlocal' then
            builtinFunc.debug_getlocal = typeInfo
         end
      end
      
   end
   
   local function process_Nilable(  )
   
      do
         local _switchExp = fieldName
         if _switchExp == 'val' then
            builtinFunc.nilable_val = typeInfo
         end
      end
      
   end
   
   
   do
      local _switchExp = name
      if _switchExp == '' then
         process_(  )
      elseif _switchExp == 'iStream' then
         process_iStream(  )
      elseif _switchExp == 'oStream' then
         process_oStream(  )
      elseif _switchExp == 'luaStream' then
         process_luaStream(  )
      elseif _switchExp == 'Mapping' then
         process_Mapping(  )
      elseif _switchExp == 'io' then
         process_io(  )
      elseif _switchExp == 'package' then
         process_package(  )
      elseif _switchExp == 'os' then
         process_os(  )
      elseif _switchExp == 'string' then
         process_string(  )
      elseif _switchExp == 'str' then
         process_str(  )
      elseif _switchExp == 'List' then
         process_List(  )
      elseif _switchExp == 'Array' then
         process_Array(  )
      elseif _switchExp == 'Set' then
         process_Set(  )
      elseif _switchExp == 'math' then
         process_math(  )
      elseif _switchExp == 'debug' then
         process_debug(  )
      elseif _switchExp == 'Nilable' then
         process_Nilable(  )
      end
   end
   
end

local function getBuiltInInfo(  )

   return {{[""] = {["_fcall"] = {["arg"] = {"form", "&..."}, ["ret"] = {""}}, ["_kind"] = {["arg"] = {"stem!"}, ["ret"] = {"int"}}, ["_load"] = {["arg"] = {"str", "stem!"}, ["ret"] = {"form!", "str!"}}, ["collectgarbage"] = {["arg"] = {}, ["ret"] = {}}, ["error"] = {["arg"] = {"str"}, ["ret"] = {"__"}}, ["load"] = {["arg"] = {"str", "str!", "str!", "stem!"}, ["ret"] = {"form!", "str!"}}, ["loadfile"] = {["arg"] = {"str"}, ["ret"] = {"form!", "str!"}}, ["print"] = {["arg"] = {"&..."}, ["ret"] = {}}, ["require"] = {["arg"] = {"str"}, ["ret"] = {"stem!"}}, ["tonumber"] = {["arg"] = {"str", "int!"}, ["ret"] = {"real!"}}, ["tostring"] = {["arg"] = {"&stem"}, ["ret"] = {"str"}}, ["type"] = {["arg"] = {"&stem!"}, ["ret"] = {"str"}}}}, {["iStream"] = {["__attrib"] = {["type"] = {"interface"}}, ["close"] = {["arg"] = {}, ["ret"] = {}, ["type"] = {"mut"}}, ["read"] = {["arg"] = {"stem!"}, ["ret"] = {"str!"}, ["type"] = {"mut"}}}}, {["oStream"] = {["__attrib"] = {["type"] = {"interface"}}, ["close"] = {["arg"] = {}, ["ret"] = {}, ["type"] = {"mut"}}, ["flush"] = {["arg"] = {}, ["ret"] = {}, ["type"] = {"mut"}}, ["write"] = {["arg"] = {"str"}, ["ret"] = {"stem!", "str!"}, ["type"] = {"mut"}}}}, {["luaStream"] = {["__attrib"] = {["inplements"] = {"iStream", "oStream"}}, ["close"] = {["arg"] = {}, ["ret"] = {}, ["type"] = {"mut"}}, ["flush"] = {["arg"] = {}, ["ret"] = {}, ["type"] = {"mut"}}, ["read"] = {["arg"] = {"stem!"}, ["ret"] = {"str!"}, ["type"] = {"mut"}}, ["seek"] = {["arg"] = {"str", "int"}, ["ret"] = {"int!", "str!"}, ["type"] = {"mut"}}, ["write"] = {["arg"] = {"str"}, ["ret"] = {"stem!", "str!"}, ["type"] = {"mut"}}}}, {["Mapping"] = {["__attrib"] = {["type"] = {"interface"}}, ["_toMap"] = {["arg"] = {}, ["ret"] = {}, ["type"] = {"method"}}}}, {["io"] = {["open"] = {["arg"] = {"str", "str!"}, ["ret"] = {"luaStream!"}}, ["popen"] = {["arg"] = {"str"}, ["ret"] = {"luaStream!"}}, ["stderr"] = {["type"] = {"member"}, ["typeInfo"] = {"oStream"}}, ["stdin"] = {["type"] = {"member"}, ["typeInfo"] = {"iStream"}}, ["stdout"] = {["type"] = {"member"}, ["typeInfo"] = {"oStream"}}}}, {["package"] = {["path"] = {["type"] = {"member"}, ["typeInfo"] = {"str"}}, ["searchpath"] = {["arg"] = {"str", "str"}, ["ret"] = {"str!"}}}}, {["os"] = {["clock"] = {["arg"] = {}, ["ret"] = {"real"}}, ["date"] = {["arg"] = {"str!", "stem!"}, ["ret"] = {"stem!"}}, ["difftime"] = {["arg"] = {"stem", "stem"}, ["ret"] = {"int"}}, ["exit"] = {["arg"] = {"int!"}, ["ret"] = {"__"}}, ["remove"] = {["arg"] = {"str"}, ["ret"] = {"bool!", "str!"}}, ["rename"] = {["arg"] = {"str", "str"}, ["ret"] = {"stem!", "str!"}}, ["time"] = {["arg"] = {"stem!"}, ["ret"] = {"stem!"}}}}, {["string"] = {["byte"] = {["arg"] = {"str", "int!", "int!"}, ["ret"] = {"int"}}, ["dump"] = {["arg"] = {"form", "bool!"}, ["ret"] = {"str"}}, ["find"] = {["arg"] = {"str", "str", "int!", "bool!"}, ["ret"] = {"int!", "int!"}}, ["format"] = {["arg"] = {"str", "..."}, ["ret"] = {"str"}}, ["gmatch"] = {["arg"] = {"str", "str"}, ["ret"] = {"form", "stem!", "stem!"}}, ["gsub"] = {["arg"] = {"str", "str", "str"}, ["ret"] = {"str", "int"}}, ["lower"] = {["arg"] = {"str"}, ["ret"] = {"str"}}, ["rep"] = {["arg"] = {"str", "int"}, ["ret"] = {"str"}}, ["reverse"] = {["arg"] = {"str"}, ["ret"] = {"str"}}, ["sub"] = {["arg"] = {"str", "int", "int!"}, ["ret"] = {"str"}}, ["upper"] = {["arg"] = {"str"}, ["ret"] = {"str"}}}}, {["str"] = {["byte"] = {["arg"] = {"int!", "int!"}, ["ret"] = {"int"}, ["type"] = {"method"}}, ["find"] = {["arg"] = {"str", "int!", "bool!"}, ["ret"] = {"int!", "int!"}, ["type"] = {"method"}}, ["format"] = {["arg"] = {"&..."}, ["ret"] = {"str"}, ["type"] = {"method"}}, ["gmatch"] = {["arg"] = {"str"}, ["ret"] = {"form", "stem!", "stem!"}, ["type"] = {"method"}}, ["gsub"] = {["arg"] = {"str", "str"}, ["ret"] = {"str", "int"}, ["type"] = {"method"}}, ["lower"] = {["arg"] = {}, ["ret"] = {"str"}, ["type"] = {"method"}}, ["rep"] = {["arg"] = {"int"}, ["ret"] = {"str"}, ["type"] = {"method"}}, ["reverse"] = {["arg"] = {}, ["ret"] = {"str"}, ["type"] = {"method"}}, ["sub"] = {["arg"] = {"int", "int!"}, ["ret"] = {"str"}, ["type"] = {"method"}}, ["upper"] = {["arg"] = {}, ["ret"] = {"str"}, ["type"] = {"method"}}}}, {["List<T>"] = {["insert"] = {["arg"] = {"&T"}, ["ret"] = {""}, ["type"] = {"mut"}}, ["remove"] = {["arg"] = {"int!"}, ["ret"] = {"T!"}, ["type"] = {"mut"}}, ["sort"] = {["arg"] = {"form!"}, ["ret"] = {}, ["type"] = {"mut"}}, ["unpack"] = {["arg"] = {}, ["ret"] = {"..."}, ["type"] = {"method"}}}}, {["Array<T>"] = {["sort"] = {["arg"] = {"form!"}, ["ret"] = {}, ["type"] = {"mut"}}, ["unpack"] = {["arg"] = {}, ["ret"] = {"..."}, ["type"] = {"method"}}}}, {["Set<T>"] = {["add"] = {["arg"] = {"T"}, ["ret"] = {}, ["type"] = {"mut"}}, ["and"] = {["arg"] = {"&Set<T>"}, ["ret"] = {"Set<T>"}, ["type"] = {"mut"}}, ["clone"] = {["arg"] = {}, ["ret"] = {"Set<T>"}, ["type"] = {"method"}}, ["del"] = {["arg"] = {"T"}, ["ret"] = {}, ["type"] = {"mut"}}, ["has"] = {["arg"] = {"T"}, ["ret"] = {"bool"}, ["type"] = {"method"}}, ["len"] = {["arg"] = {}, ["ret"] = {"int"}, ["type"] = {"method"}}, ["or"] = {["arg"] = {"&Set<T>"}, ["ret"] = {"Set<T>"}, ["type"] = {"mut"}}, ["sub"] = {["arg"] = {"&Set<T>"}, ["ret"] = {"Set<T>"}, ["type"] = {"mut"}}}}, {["math"] = {["random"] = {["arg"] = {"int!", "int!"}, ["ret"] = {"real"}}, ["randomseed"] = {["arg"] = {"int!"}, ["ret"] = {}}}}, {["debug"] = {["getinfo"] = {["arg"] = {"int"}, ["ret"] = {"stem!"}}, ["getlocal"] = {["arg"] = {"int", "int"}, ["ret"] = {"str!", "stem!"}}}}, {["Nilable"] = {["val"] = {["arg"] = {}, ["ret"] = {"_T!"}, ["type"] = {"method"}}}}}
end


local function isStrFormFunc( typeInfo )

   if typeInfo:equals( builtinFunc.string_format ) then
      return true
   end
   
   return false
end
_moduleObj.isStrFormFunc = isStrFormFunc
local readyBuiltin = false
function TransUnit:registBuiltInScope(  )

   if readyBuiltin then
      return 
   end
   
   readyBuiltin = true
   local builtInInfo = getBuiltInInfo(  )
   local function getTypeInfo( typeName )
   
      do
         local _switchExp = typeName
         if _switchExp == "_T" then
            return Ast.builtinTypeBox:get_boxingType()
         elseif _switchExp == "_T!" then
            return Ast.builtinTypeBox:get_boxingType():get_nilableTypeInfo()
         end
      end
      
      local function getTypeInfoFromScope( scope, symbol, genTyeList )
      
         local typeInfo = scope:getTypeInfo( symbol, scope, false )
         if  nil == typeInfo then
            local _typeInfo = typeInfo
         
            return nil
         end
         
         return typeInfo
      end
      
      local mutable = true
      if typeName:find( "^&" ) then
         mutable = false
         typeName = typeName:gsub( "^&", "" )
      end
      
      local genTypeList = {}
      local index, endIndex = typeName:find( "[%w]+<" )
      if index ~= nil and endIndex ~= nil then
         local genTypeName = typeName:sub( endIndex )
         do
            local tailIndex = genTypeName:find( "[,>]" )
            if tailIndex ~= nil then
               local genType = getTypeInfo( genTypeName:sub( 2, tailIndex - 1 ) )
               table.insert( genTypeList, genType )
            end
         end
         
         typeName = typeName:sub( 1, endIndex - 1 )
      end
      
      local typeInfo = Ast.headTypeInfo
      if typeName:find( "!$" ) then
         local orgTypeName = typeName:gsub( "!$", "" )
         do
            local _exp = getTypeInfoFromScope( self.scope, orgTypeName, genTypeList )
            if _exp ~= nil then
               typeInfo = _exp
            else
               Util.err( string.format( "not found builtin -- %s", orgTypeName) )
            end
         end
         
         typeInfo = typeInfo:get_nilableTypeInfo()
      else
       
         do
            local _exp = getTypeInfoFromScope( self.scope, typeName, genTypeList )
            if _exp ~= nil then
               typeInfo = _exp
            else
               Util.err( string.format( "not found builtin -- %s", typeName) )
            end
         end
         
      end
      
      if mutable then
         return typeInfo
      end
      
      typeInfo = self:createModifier( typeInfo, Ast.MutMode.IMut )
      return typeInfo
   end
   
   local function processField( name, fieldName, info, parentInfo )
   
      if self.targetLuaVer:isSupport( string.format( "%s.%s", name, fieldName) ) then
         if _lune.nilacc( info['type'], nil, 'item', 1) == "member" then
            self.scope:addMember( fieldName, getTypeInfo( _lune.unwrap( _lune.nilacc( info['typeInfo'], nil, 'item', 1)) ), Ast.AccessMode.Pub, true, Ast.MutMode.Mut )
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
            local typeInfo = Ast.NormalTypeInfo.createFunc( false, true, self.scope, methodFlag and Ast.TypeInfoKind.Method or Ast.TypeInfoKind.Func, parentInfo, false, true, not methodFlag, Ast.AccessMode.Pub, fieldName, nil, argTypeList, retTypeList, mutable )
            self:popScope(  )
            Ast.builtInTypeIdSet[typeInfo:get_typeId(  )] = typeInfo
            if typeInfo:get_nilableTypeInfo() ~= Ast.headTypeInfo then
               Ast.builtInTypeIdSet[typeInfo:get_nilableTypeInfo():get_typeId()] = typeInfo:get_nilableTypeInfo()
            end
            
            self.scope:add( methodFlag and Ast.SymbolKind.Mtd or Ast.SymbolKind.Fun, not methodFlag, not methodFlag, fieldName, typeInfo, Ast.AccessMode.Pub, not methodFlag, mutable and Ast.MutMode.Mut or Ast.MutMode.IMut, true )
            setupBuiltinTypeInfo( name, fieldName, typeInfo )
         end
         
      end
      
   end
   
   self.scope = Ast.rootScope
   local builtinModuleName2Scope = {}
   local mapType = Ast.NormalTypeInfo.createMap( Ast.AccessMode.Pub, Ast.headTypeInfo, Ast.builtinTypeString, Ast.builtinTypeStem, Ast.MutMode.Mut )
   self.scope:addVar( Ast.AccessMode.Global, "_ENV", mapType, Ast.MutMode.IMutRe, true )
   self.scope:addVar( Ast.AccessMode.Global, "_G", mapType, Ast.MutMode.IMutRe, true )
   self.scope:addVar( Ast.AccessMode.Global, "_VERSION", Ast.builtinTypeString, Ast.MutMode.IMut, true )
   self.scope:addVar( Ast.AccessMode.Global, "__mod__", Ast.builtinTypeString, Ast.MutMode.IMut, true )
   self.scope:addVar( Ast.AccessMode.Global, "__line__", Ast.builtinTypeInt, Ast.MutMode.IMut, true )
   for __index, builtinClassInfo in pairs( builtInInfo ) do
      for className, name2FieldInfo in pairs( builtinClassInfo ) do
         local name = className
         local genTypeList = {}
         if className:find( "<" ) then
            name = ""
            for token in className:gmatch( "[^<>,%s]+" ) do
               if #name == 0 then
                  name = token
               else
                
                  table.insert( genTypeList, Ast.NormalTypeInfo.createAlternate( true, #genTypeList + 1, token, Ast.AccessMode.Pri, self.moduleType ) )
               end
               
            end
            
         end
         
         local parentInfo = Ast.headTypeInfo
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
            
            parentInfo = self:pushClass( classFlag, false, nil, interfaceList, genTypeList, true, name, Ast.AccessMode.Pub )
            Ast.builtInTypeIdSet[parentInfo:get_typeId(  )] = parentInfo
            Ast.builtInTypeIdSet[parentInfo:get_nilableTypeInfo():get_typeId()] = parentInfo:get_nilableTypeInfo()
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
                  local info = __map[ fieldName ]
                  do
                     do
                        local _switchExp = fieldName
                        if _switchExp == "__attrib" then
                        else 
                           
                              processField( name, fieldName, info, parentInfo )
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
   
   self.scope = self.topScope
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
   
   for __index, mess in pairs( self.warnMessList ) do
      Util.errorLog( mess )
   end
   
   if self.macroMode ~= Nodes.MacroMode.None then
      print( "------ near code -----" )
      local code = ""
      for index = #self.usedTokenList - 20, #self.usedTokenList do
         if index > 1 then
            code = string.format( "%s %s", code, self.usedTokenList[index].txt)
         end
         
      end
      
      print( code .. self.currentToken.txt )
      print( "------" )
   end
   
   Util.err( "has error" )
end

function TransUnit:createNoneNode( pos )

   return Nodes.NoneNode.create( self.nodeManager, pos, {Ast.builtinTypeNone} )
end

function TransUnit:pushbackToken( token )

   if token ~= Parser.getEofToken(  ) then
      table.insert( self.pushbackList, token )
   end
   
   self.currentToken = self.usedTokenList[#self.usedTokenList]
end

local function expandVal( tokenList, val, pos )

   if val ~= nil then
      do
         local _switchExp = type( val )
         if _switchExp == "boolean" then
            local token = string.format( "%s", tostring( val))
            local kind = Parser.TokenKind.Kywd
            table.insert( tokenList, Parser.Token.new(kind, token, pos, false) )
         elseif _switchExp == "number" then
            local num = string.format( "%g", val * 1.0)
            local kind = Parser.TokenKind.Int
            if string.find( num, ".", 1, true ) then
               kind = Parser.TokenKind.Real
            end
            
            table.insert( tokenList, Parser.Token.new(kind, num, pos, false) )
         elseif _switchExp == "string" then
            table.insert( tokenList, Parser.Token.new(Parser.TokenKind.Str, string.format( '[[%s]]', tostring( val)), pos, false) )
         else 
            
               return string.format( "not support ,, List -- %s", type( val ))
         end
      end
      
   end
   
   return nil
end

function TransUnit:newPushback( tokenList )

   for index = #tokenList, 1, -1 do
      table.insert( self.pushbackList, tokenList[index] )
   end
   
   self.currentToken = self.usedTokenList[#self.usedTokenList]
end

function TransUnit:expandMacroVal( token )

   local tokenTxt = token.txt
   if tokenTxt == ',,' or tokenTxt == ',,,' or tokenTxt == ',,,,' then
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
               nextToken = Parser.Token.new(nextToken.kind, txtList[index], nextToken.pos, false)
               self:pushbackToken( nextToken )
            end
            
         elseif macroVal.typeInfo:equals( Ast.builtinTypeStat ) then
            self:pushbackStr( string.format( "macroVal %s", nextToken.txt), (_lune.unwrap( macroVal.val) ) )
         elseif macroVal.typeInfo:get_kind(  ) == Ast.TypeInfoKind.Array or macroVal.typeInfo:get_kind(  ) == Ast.TypeInfoKind.List then
            if macroVal.typeInfo:get_itemTypeInfoList()[1]:equals( Ast.builtinTypeStat ) then
               local strList = (_lune.unwrap( macroVal.val) )
               for index = #strList, 1, -1 do
                  self:pushbackStr( string.format( "macroVal %s[%d]", nextToken.txt, index), strList[index] )
               end
               
            else
             
               local tokenList = {}
               do
                  local argNode = macroVal.argNode
                  if argNode ~= nil then
                     if not argNode:setupLiteralTokenList( tokenList ) then
                        self:error( string.format( "illegal macro val ,, -- %s", nextToken.txt) )
                     end
                     
                  else
                     self:error( string.format( "not support ,, -- %s", nextToken.txt) )
                  end
               end
               
               self:newPushback( tokenList )
            end
            
         elseif macroVal.typeInfo:get_kind(  ) == Ast.TypeInfoKind.Enum then
            local enumTypeInfo = _lune.unwrap( _lune.__Cast( macroVal.typeInfo, 3, Ast.EnumTypeInfo ))
            local fullname = macroVal.typeInfo:getFullName( self.importModule2ModuleInfoCurrent, true )
            local nameList = {}
            for name in fullname:gmatch( "[^%.]+" ) do
               table.insert( nameList, name )
            end
            
            local enumValInfo = _lune.unwrap( enumTypeInfo:get_val2EnumValInfo()[_lune.unwrap( macroVal.val)])
            nextToken = Parser.Token.new(Parser.TokenKind.Symb, enumValInfo:get_name(), nextToken.pos, false)
            self:pushbackToken( nextToken )
            for index = #nameList, 1, -1 do
               nextToken = Parser.Token.new(Parser.TokenKind.Dlmt, ".", nextToken.pos, false)
               self:pushbackToken( nextToken )
               nextToken = Parser.Token.new(Parser.TokenKind.Symb, nameList[index], nextToken.pos, false)
               self:pushbackToken( nextToken )
            end
            
         else
          
            local tokenList = {}
            do
               local argNode = macroVal.argNode
               if argNode ~= nil then
                  if not argNode:setupLiteralTokenList( tokenList ) then
                     self:error( string.format( "illegal macro val ,, -- %s", nextToken.txt) )
                  end
                  
               else
                  expandVal( tokenList, macroVal.val, nextToken.pos )
               end
            end
            
            self:newPushback( tokenList )
         end
         
      elseif tokenTxt == ',,,' then
         if macroVal.typeInfo:equals( Ast.builtinTypeString ) then
            nextToken = Parser.Token.new(nextToken.kind, (_lune.unwrap( macroVal.val) ), nextToken.pos, false)
            self:pushbackToken( nextToken )
         end
         
      elseif tokenTxt == ',,,,' then
         if macroVal.typeInfo:equals( Ast.builtinTypeSymbol ) then
            local txtList = (_lune.unwrap( macroVal.val) )
            local newToken = ""
            for __index, txt in pairs( txtList ) do
               newToken = string.format( "%s%s", newToken, txt)
            end
            
            nextToken = Parser.Token.new(Parser.TokenKind.Str, string.format( "'%s'", newToken), nextToken.pos, false)
            self:pushbackToken( nextToken )
         elseif macroVal.typeInfo:equals( Ast.builtinTypeStat ) then
            nextToken = Parser.Token.new(Parser.TokenKind.Str, string.format( "'%s'", tostring( _lune.unwrap( macroVal.val))), nextToken.pos, false)
            self:pushbackToken( nextToken )
         else
          
            self:error( string.format( "not support this symbol -- %s%s", tokenTxt, nextToken.txt) )
         end
         
      end
      
      nextToken = self:getTokenNoErr(  )
      token = nextToken
   end
   
   return token
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
         if self.macroMode == Nodes.MacroMode.Expand then
            token = self:expandMacroVal( _exp )
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

local SymbolMode = {}
SymbolMode._val2NameMap = {}
function SymbolMode:_getTxt( val )
   local name = self._val2NameMap[ val ]
   if name then
      return string.format( "SymbolMode.%s", name )
   end
   return string.format( "illegal val -- %s", val )
end
function SymbolMode._from( val )
   if SymbolMode._val2NameMap[ val ] then
      return val
   end
   return nil
end
    
SymbolMode.__allList = {}
function SymbolMode.get__allList()
   return SymbolMode.__allList
end

SymbolMode.Must_ = 0
SymbolMode._val2NameMap[0] = 'Must_'
SymbolMode.__allList[1] = SymbolMode.Must_
SymbolMode.MustNot_ = 1
SymbolMode._val2NameMap[1] = 'MustNot_'
SymbolMode.__allList[2] = SymbolMode.MustNot_

local specialSymbolMap = {["__init"] = true, ["__free"] = true, ["__"] = true, ["_exp"] = true}
function TransUnit:checkSymbol( token, mode )

   if token.kind ~= Parser.TokenKind.Symb and token.kind ~= Parser.TokenKind.Kywd and token.kind ~= Parser.TokenKind.Type then
      self:addErrMess( token.pos, string.format( "illegal symbol -- '%s'", token.txt) )
   end
   
   local frontChar = string.byte( token.txt, 1 )
   if mode == SymbolMode.Must_ and frontChar ~= 95 then
      self:addErrMess( token.pos, string.format( "macro name must begin with '_' -- '%s'", token.txt) )
   elseif mode == SymbolMode.MustNot_ and frontChar == 95 then
      if not self.ignoreToCheckSymbol_ then
         if not specialSymbolMap[token.txt] then
            self:addErrMess( token.pos, string.format( "symbol must not begin with '_' -- '%s'", token.txt) )
         end
         
      end
      
   elseif token.txt == "self" then
      self:addErrMess( token.pos, string.format( "this symbol is special keyword -- %s", token.txt) )
   end
   
   return token
end

function TransUnit:getSymbolToken( mode )

   return self:checkSymbol( self:getToken(  ), mode )
end

function TransUnit:checkToken( token, txt )

   if token.txt ~= txt then
      self:error( string.format( "not found -- %s", txt) )
   end
   
   return token
end

function TransUnit:checkNextToken( txt )

   return self:checkToken( self:getToken(  ), txt )
end

function TransUnit:getContinueToken(  )

   local token = self:getToken(  )
   return token, token.consecutive
end

function TransUnit:analyzeStatementList( stmtList, termTxt )

   local breakKind = Nodes.BreakKind.None
   if #stmtList > 0 then
      breakKind = stmtList[#stmtList]:getBreakKind( Nodes.CheckBreakMode.Normal )
   end
   
   local lastStatement = nil
   while true do
      local statement = self:analyzeStatement( termTxt )
      do
         local _exp = statement
         if _exp ~= nil then
            if breakKind ~= Nodes.BreakKind.None then
               self:addErrMess( _exp:get_pos(), string.format( "This statement is not reached -- %s", Nodes.BreakKind:_getTxt( breakKind)
               ) )
            end
            
            table.insert( stmtList, _exp )
            lastStatement = statement
            breakKind = _exp:getBreakKind( Nodes.CheckBreakMode.Normal )
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
         if _exp:get_kind() ~= Nodes.NodeKind.get_Subfile() then
            self:error( "subfile must have 'subfile' declaration at top." )
         end
         
      else
         self:error( "subfile must have 'subfile' declaration at top." )
      end
   end
   
   return self:analyzeStatementList( stmtList )
end

function TransUnit:analyzeLuneControl( firstToken )

   local node = nil
   local nextToken = self:getToken(  )
   do
      local _switchExp = (nextToken.txt )
      if _switchExp == LuneControl.Pragma.disable_mut_control then
         self.validMutControl = false
      elseif _switchExp == LuneControl.Pragma.ignore_symbol_ then
         self.ignoreToCheckSymbol_ = true
      elseif _switchExp == LuneControl.Pragma.load__lune_module then
         node = Nodes.LuneControlNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeNone}, LuneControl.Pragma.load__lune_module )
      else 
         
            self:addErrMess( nextToken.pos, string.format( "unknown option -- %s", nextToken.txt) )
      end
   end
   
   self:checkNextToken( ";" )
   return node
end

local TentativeMode = {}
TentativeMode._val2NameMap = {}
function TentativeMode:_getTxt( val )
   local name = self._val2NameMap[ val ]
   if name then
      return string.format( "TentativeMode.%s", name )
   end
   return string.format( "illegal val -- %s", val )
end
function TentativeMode._from( val )
   if TentativeMode._val2NameMap[ val ] then
      return val
   end
   return nil
end
    
TentativeMode.__allList = {}
function TentativeMode.get__allList()
   return TentativeMode.__allList
end

TentativeMode.Ignore = 0
TentativeMode._val2NameMap[0] = 'Ignore'
TentativeMode.__allList[1] = TentativeMode.Ignore
TentativeMode.Loop = 1
TentativeMode._val2NameMap[1] = 'Loop'
TentativeMode.__allList[2] = TentativeMode.Loop
TentativeMode.Simple = 2
TentativeMode._val2NameMap[2] = 'Simple'
TentativeMode.__allList[3] = TentativeMode.Simple
TentativeMode.Start = 3
TentativeMode._val2NameMap[3] = 'Start'
TentativeMode.__allList[4] = TentativeMode.Start
TentativeMode.Merge = 4
TentativeMode._val2NameMap[4] = 'Merge'
TentativeMode.__allList[5] = TentativeMode.Merge
TentativeMode.Finish = 5
TentativeMode._val2NameMap[5] = 'Finish'
TentativeMode.__allList[6] = TentativeMode.Finish

function TransUnit:analyzeBlock( blockKind, tentativeMode, scope )

   local token = self:checkNextToken( "{" )
   if not scope then
      self:pushScope( false )
   end
   
   local blockScope = self.scope
   do
      local _switchExp = tentativeMode
      if _switchExp == TentativeMode.Simple or _switchExp == TentativeMode.Start or _switchExp == TentativeMode.Ignore or _switchExp == TentativeMode.Loop then
         self:prepareTentativeSymbol( self.scope, tentativeMode == TentativeMode.Loop )
      elseif _switchExp == TentativeMode.Merge or _switchExp == TentativeMode.Finish then
         self:mergeTentativeSymbol( self.scope )
      end
   end
   
   local loopFlag = false
   do
      local _switchExp = blockKind
      if _switchExp == Nodes.BlockKind.For or _switchExp == Nodes.BlockKind.Apply or _switchExp == Nodes.BlockKind.While or _switchExp == Nodes.BlockKind.Repeat or _switchExp == Nodes.BlockKind.Foreach then
         loopFlag = true
         table.insert( self.loopScopeQueue, self.scope )
      end
   end
   
   local stmtList = {}
   self:analyzeStatementList( stmtList, "}" )
   self:checkNextToken( "}" )
   if loopFlag then
      table.remove( self.loopScopeQueue )
   end
   
   if not scope then
      self:popScope(  )
   end
   
   local node = Nodes.BlockNode.create( self.nodeManager, token.pos, {Ast.builtinTypeNone}, blockKind, blockScope, stmtList )
   if node:getBreakKind( Nodes.CheckBreakMode.Normal ) ~= Nodes.BreakKind.None then
      self.tentativeSymbol:skip(  )
   end
   
   do
      local _switchExp = tentativeMode
      if _switchExp == TentativeMode.Simple or _switchExp == TentativeMode.Finish then
         self:finishTentativeSymbol( true )
      elseif _switchExp == TentativeMode.Ignore or _switchExp == TentativeMode.Loop then
         self:finishTentativeSymbol( false )
      end
   end
   
   return node
end

local ExtMacroInfo = {}
setmetatable( ExtMacroInfo, { __index = Nodes.MacroInfo } )
_moduleObj.ExtMacroInfo = ExtMacroInfo
function ExtMacroInfo:getArgList(  )

   return self.argList
end
function ExtMacroInfo:getTokenList(  )

   return self.tokenList
end
function ExtMacroInfo.new( name, func, symbol2MacroValInfoMap, argList, tokenList )
   local obj = {}
   ExtMacroInfo.setmeta( obj )
   if obj.__init then obj:__init( name, func, symbol2MacroValInfoMap, argList, tokenList ); end
   return obj
end
function ExtMacroInfo:__init(name, func, symbol2MacroValInfoMap, argList, tokenList) 
   Nodes.MacroInfo.__init( self,func, symbol2MacroValInfoMap)
   
   self.name = name
   self.argList = argList
   self.tokenList = tokenList
end
function ExtMacroInfo.setmeta( obj )
  setmetatable( obj, { __index = ExtMacroInfo  } )
end
function ExtMacroInfo:get_name()
   return self.name
end

local DependModuleInfo = {}
function DependModuleInfo:getTypeInfo( metaTypeId )

   return _lune.unwrap( self.metaTypeId2TypeInfoMap[metaTypeId])
end
function DependModuleInfo.setmeta( obj )
  setmetatable( obj, { __index = DependModuleInfo  } )
end
function DependModuleInfo.new( id, metaTypeId2TypeInfoMap )
   local obj = {}
   DependModuleInfo.setmeta( obj )
   if obj.__init then
      obj:__init( id, metaTypeId2TypeInfoMap )
   end
   return obj
end
function DependModuleInfo:__init( id, metaTypeId2TypeInfoMap )

   self.id = id
   self.metaTypeId2TypeInfoMap = metaTypeId2TypeInfoMap
end

function TransUnit:processImport( modulePath )
   local __func__ = 'TransUnit.processImport'

   Log.log( Log.Level.Info, __func__, 2267, function (  )
   
      return string.format( "%s start", modulePath)
   end
    )
   
   if not self.importModuleInfo:add( modulePath ) then
      self:error( string.format( "recursive import: %s -> %s", self.importModuleInfo:getFull(  ), modulePath) )
   end
   
   do
      local moduleInfo = self.importModuleName2ModuleInfo[modulePath]
      if moduleInfo ~= nil then
         do
            local metaInfoStem = frontInterface.loadMeta( self.importModuleInfo, modulePath )
            if metaInfoStem ~= nil then
               Log.log( Log.Level.Info, __func__, 2278, function (  )
               
                  return string.format( "%s already", modulePath)
               end
                )
               
               local metaInfo = metaInfoStem
               local typeId2TypeInfo = moduleInfo:get_importId2localTypeInfoMap()
               local moduleTypeInfo = _lune.unwrap( typeId2TypeInfo[metaInfo.__moduleTypeId])
               self.importModuleInfo:remove(  )
               return metaInfo, typeId2TypeInfo, moduleInfo
            end
         end
         
         self:error( "failed to load meta -- " .. modulePath )
      end
   end
   
   local nameList = {}
   for txt in string.gmatch( modulePath, '[^%.]+' ) do
      table.insert( nameList, txt )
   end
   
   local metaInfoStem = frontInterface.loadMeta( self.importModuleInfo, modulePath )
   if  nil == metaInfoStem then
      local _metaInfoStem = metaInfoStem
   
      self:error( "failed to load meta -- " .. modulePath )
   end
   
   local metaInfo = metaInfoStem
   Log.log( Log.Level.Info, __func__, 2298, function (  )
   
      return string.format( "%s processing", modulePath)
   end
    )
   
   local dependLibId2DependInfo = {}
   do
      local __sorted = {}
      local __map = metaInfo.__dependModuleMap
      for __key in pairs( __map ) do
         table.insert( __sorted, __key )
      end
      table.sort( __sorted )
      for __index, dependName in ipairs( __sorted ) do
         local dependInfo = __map[ dependName ]
         do
            if dependInfo['use'] then
               local workModuleInfo, metaTypeId2TypeInfoMap = self:processImport( dependName )
               local typeId = math.floor((_lune.unwrap( dependInfo['typeId']) ))
               dependLibId2DependInfo[typeId] = DependModuleInfo.new(typeId, metaTypeId2TypeInfoMap)
            end
            
         end
      end
   end
   
   local typeId2TypeInfo = {}
   typeId2TypeInfo[Ast.rootTypeId] = Ast.headTypeInfo
   local typeId2Scope = {}
   typeId2Scope[Ast.rootTypeId] = self.scope
   for typeId, dependIdInfo in pairs( metaInfo.__dependIdMap ) do
      local dependInfo = _lune.unwrap( dependLibId2DependInfo[dependIdInfo[1]])
      local typeInfo = dependInfo:getTypeInfo( dependIdInfo[2] )
      typeId2TypeInfo[typeId] = typeInfo
      do
         local _exp = Ast.getScope( typeInfo )
         if _exp ~= nil then
            typeId2Scope[typeId] = _exp
         end
      end
      
   end
   
   local moduleTypeInfo = Ast.headTypeInfo
   for index, moduleName in pairs( nameList ) do
      local mutable = false
      if index == #nameList then
         mutable = metaInfo.__moduleMutable
      end
      
      moduleTypeInfo = self:pushModule( true, moduleName, mutable )
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
   
   local newId2OldIdMap = {}
   local _typeInfoList = {}
   local id2atomMap = {}
   local _typeInfoNormalList = {}
   for __index, atomInfo in pairs( metaInfo.__typeInfoList ) do
      do
         local skind = atomInfo['skind']
         if skind ~= nil then
            local actInfo = nil
            local mess = nil
            local kind = _lune.unwrap( Ast.SerializeKind._from( math.floor(skind) ))
            do
               local _switchExp = kind
               if _switchExp == Ast.SerializeKind.Enum then
                  actInfo = _TypeInfoEnum._fromMap( atomInfo )
               elseif _switchExp == Ast.SerializeKind.Alge then
                  actInfo = _TypeInfoAlge._fromMap( atomInfo )
                  self.helperInfo.useAlge = true
               elseif _switchExp == Ast.SerializeKind.Module then
                  actInfo = _TypeInfoModule._fromMap( atomInfo )
               elseif _switchExp == Ast.SerializeKind.Normal then
                  do
                     local _exp = _TypeInfoNormal._fromMap( atomInfo )
                     if _exp ~= nil then
                        table.insert( _typeInfoNormalList, _exp )
                        actInfo = _exp
                     end
                  end
                  
               elseif _switchExp == Ast.SerializeKind.Nilable then
                  actInfo = _TypeInfoNilable._fromMap( atomInfo )
               elseif _switchExp == Ast.SerializeKind.Alias then
                  actInfo = _TypeInfoAlias._fromMap( atomInfo )
               elseif _switchExp == Ast.SerializeKind.DDD then
                  actInfo, mess = _TypeInfoDDD._fromMap( atomInfo )
               elseif _switchExp == Ast.SerializeKind.Alternate then
                  actInfo, mess = _TypeInfoAlternate._fromMap( atomInfo )
               elseif _switchExp == Ast.SerializeKind.Generic then
                  actInfo, mess = _TypeInfoGeneric._fromMap( atomInfo )
               elseif _switchExp == Ast.SerializeKind.Modifier then
                  actInfo = _TypeInfoModifier._fromMap( atomInfo )
               elseif _switchExp == Ast.SerializeKind.Box then
                  actInfo = _TypeInfoBox._fromMap( atomInfo )
               else 
                  
                     Util.err( string.format( "unknown skind -- %d", math.floor(skind)) )
               end
            end
            
            if actInfo ~= nil then
               table.insert( _typeInfoList, actInfo )
               id2atomMap[actInfo.typeId] = actInfo
            else
               for key, val in pairs( atomInfo ) do
                  Util.errorLog( string.format( "table: %s:%s", key, tostring( val)) )
               end
               
               if mess ~= nil then
                  Util.errorLog( mess )
               end
               
               Util.err( string.format( "_TypeInfo.%s._fromMap error", Ast.SerializeKind:_getTxt( kind)
               ) )
            end
            
         end
      end
      
   end
   
   local orgId2MacroTypeInfo = {}
   local importParam = ImportParam.new(self, typeId2Scope, typeId2TypeInfo, metaInfo, self.scope, moduleTypeInfo, id2atomMap)
   for __index, atomInfo in pairs( _typeInfoList ) do
      local newTypeInfo, errMess = atomInfo:createTypeInfo( importParam )
      do
         local _exp = errMess
         if _exp ~= nil then
            Util.err( string.format( "%s: %s", modulePath, _exp) )
         end
      end
      
      if newTypeInfo ~= nil then
         if newTypeInfo:get_kind() == Ast.TypeInfoKind.Macro then
            orgId2MacroTypeInfo[atomInfo.typeId] = newTypeInfo
         end
         
         if newTypeInfo:get_kind() == Ast.TypeInfoKind.Set then
            self.helperInfo.useSet = true
         end
         
         if newTypeInfo:get_accessMode() == Ast.AccessMode.Global then
            do
               local _switchExp = newTypeInfo:get_kind()
               if _switchExp == Ast.TypeInfoKind.IF or _switchExp == Ast.TypeInfoKind.Class then
                  self.globalScope:addClass( newTypeInfo:get_rawTxt(), newTypeInfo )
               elseif _switchExp == Ast.TypeInfoKind.Func then
                  self.globalScope:addFunc( newTypeInfo, Ast.AccessMode.Global, newTypeInfo:get_staticFlag(), Ast.TypeInfo.isMut( newTypeInfo ) )
               elseif _switchExp == Ast.TypeInfoKind.Enum then
                  self.globalScope:addEnum( Ast.AccessMode.Global, newTypeInfo:get_rawTxt(), newTypeInfo )
               elseif _switchExp == Ast.TypeInfoKind.Nilable then
                  
               else 
                  
                     Util.err( string.format( "%s: not support kind -- %s", __func__, Ast.TypeInfoKind:_getTxt( newTypeInfo:get_kind())
                     ) )
               end
            end
            
         end
         
      end
      
   end
   
   for __index, atomInfo in pairs( _typeInfoNormalList ) do
      if #atomInfo.children > 0 then
         local scope = _lune.unwrap( typeId2Scope[atomInfo.typeId])
         for __index, childId in pairs( atomInfo.children ) do
            local typeInfo = typeId2TypeInfo[childId]
            if  nil == typeInfo then
               local _typeInfo = typeInfo
            
               Util.err( string.format( "not found childId -- %s, %d, %s(%d)", modulePath, childId, atomInfo.txt, atomInfo.typeId) )
            end
            
            local symbolKind = Ast.SymbolKind.Typ
            local addFlag = true
            do
               local _switchExp = typeInfo:get_kind()
               if _switchExp == Ast.TypeInfoKind.Func then
                  symbolKind = Ast.SymbolKind.Fun
               elseif _switchExp == Ast.TypeInfoKind.Form or _switchExp == Ast.TypeInfoKind.FormFunc then
                  symbolKind = Ast.SymbolKind.Typ
               elseif _switchExp == Ast.TypeInfoKind.Method then
                  symbolKind = Ast.SymbolKind.Mtd
               elseif _switchExp == Ast.TypeInfoKind.Class or _switchExp == Ast.TypeInfoKind.Module then
                  symbolKind = Ast.SymbolKind.Typ
               elseif _switchExp == Ast.TypeInfoKind.Enum then
                  addFlag = false
               end
            end
            
            if addFlag then
               scope:add( symbolKind, false, typeInfo:get_kind() == Ast.TypeInfoKind.Func, typeInfo:getTxt(  ), typeInfo, typeInfo:get_accessMode(), typeInfo:get_staticFlag(), typeInfo:get_mutMode(), true )
            end
            
         end
         
      end
      
   end
   
   for typeId, typeInfo in pairs( typeId2TypeInfo ) do
      newId2OldIdMap[typeInfo] = typeId
   end
   
   local function registMember( classTypeId )
   
      if metaInfo.__dependIdMap[classTypeId] then
         return 
      end
      
      local classTypeInfo = _lune.unwrap( typeId2TypeInfo[classTypeId])
      do
         local _switchExp = (classTypeInfo:get_kind() )
         if _switchExp == Ast.TypeInfoKind.Class then
            self:pushClass( true, classTypeInfo:get_abstractFlag(), nil, nil, {}, true, classTypeInfo:getTxt(  ), Ast.AccessMode.Pub )
            do
               local _exp = metaInfo.__typeId2ClassInfoMap[classTypeId]
               if _exp ~= nil then
                  local classInfo = _exp
                  for fieldName, fieldInfo in pairs( classInfo ) do
                     do
                        local typeId = fieldInfo['typeId']
                        if typeId ~= nil then
                           local fieldTypeInfo = _lune.unwrap( typeId2TypeInfo[math.floor(typeId)])
                           local symbolInfo = self.scope:addMember( fieldName, fieldTypeInfo, _lune.unwrap( Ast.AccessMode._from( math.floor((_lune.unwrap( fieldInfo['accessMode']) )) )), fieldInfo['staticFlag'] and true or false, _lune.unwrap( Ast.MutMode._from( math.floor((_lune.unwrap( fieldInfo['mutMode']) )) )) )
                        else
                           self:error( "not found fieldInfo.typeId" )
                        end
                     end
                     
                  end
                  
               else
                  self:error( string.format( "not found class -- %s: %d, %s", modulePath, classTypeId, classTypeInfo:getTxt(  )) )
               end
            end
            
         elseif _switchExp == Ast.TypeInfoKind.Module then
            self:pushModule( true, classTypeInfo:getTxt(  ), Ast.TypeInfo.isMut( classTypeInfo ) )
         end
      end
      
      for __index, child in pairs( classTypeInfo:get_children(  ) ) do
         if child:get_kind(  ) == Ast.TypeInfoKind.Class or child:get_kind(  ) == Ast.TypeInfoKind.Module or child:get_kind(  ) == Ast.TypeInfoKind.IF then
            local oldId = newId2OldIdMap[child]
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
   
   for __index, atomInfo in pairs( _typeInfoList ) do
      if atomInfo.parentId == Ast.rootTypeId and (atomInfo.skind == Ast.SerializeKind.Normal or atomInfo.skind == Ast.SerializeKind.Module ) then
         registMember( atomInfo.typeId )
      end
      
   end
   
   for index, moduleName in pairs( nameList ) do
      local mutable = false
      if index == #nameList then
         mutable = metaInfo.__moduleMutable
      end
      
      self:pushModule( true, moduleName, mutable )
   end
   
   for varName, varInfo in pairs( metaInfo.__varName2InfoMap ) do
      do
         local typeId = varInfo['typeId']
         if typeId ~= nil then
            self.scope:addStaticVar( false, true, varName, _lune.unwrap( typeId2TypeInfo[math.floor(typeId)]), varInfo['mutable'] and Ast.MutMode.Mut or Ast.MutMode.IMut )
         else
            self:error( "illegal varInfo.typeId" )
         end
      end
      
   end
   
   for orgTypeId, macroInfoStem in pairs( metaInfo.__macroName2InfoMap ) do
      local macroInfo, err = MacroMetaInfo._fromStem( macroInfoStem )
      if macroInfo ~= nil then
         local macroTypeInfo = _lune.unwrap( orgId2MacroTypeInfo[orgTypeId])
         local argList = {}
         local argNameList = {}
         local symbol2MacroValInfoMap = {}
         for __index, argInfo in pairs( macroInfo.argList ) do
            local argTypeInfo = _lune.unwrap( typeId2TypeInfo[argInfo.typeId])
            table.insert( argList, Nodes.MacroArgInfo.new(argInfo.name, argTypeInfo) )
            table.insert( argNameList, argInfo.name )
         end
         
         for __index, symInfo in pairs( macroInfo.symList ) do
            local symTypeInfo = _lune.unwrap( typeId2TypeInfo[symInfo.typeId])
            symbol2MacroValInfoMap[symInfo.name] = Nodes.MacroValInfo.new(nil, symTypeInfo, nil)
         end
         
         local tokenList = {}
         local lineNo = 0
         local column = 1
         for __index, tokenInfo in pairs( macroInfo.tokenList ) do
            local txt = tokenInfo[2]
            if txt == "\n" then
               lineNo = lineNo + 1
               column = 1
            else
             
               table.insert( tokenList, Parser.Token.new(_lune.unwrap( Parser.TokenKind._from( math.floor(tokenInfo[1]) )), txt, Parser.Position.new(lineNo, column), false) )
               column = column + #txt + 1
            end
            
         end
         
         self.typeId2MacroInfo[macroTypeInfo:get_typeId()] = ExtMacroInfo.new(macroInfo.name, self.macroEval:evalFromCode( macroInfo.name, argNameList, macroInfo.stmtBlock ), symbol2MacroValInfoMap, argList, tokenList)
      else
         Util.errorLog( string.format( "macro load fail -- %s", _lune.unwrapDefault( err, "")) )
      end
      
   end
   
   for __index, moduleName in pairs( nameList ) do
      self:popModule(  )
   end
   
   local moduleInfo = Nodes.ModuleInfo.new(modulePath, nameList[#nameList], newId2OldIdMap, frontInterface.ModuleId.createIdFromTxt( metaInfo.__buildId ))
   self.importModule2ModuleInfo[moduleTypeInfo] = moduleInfo
   self.importModuleName2ModuleInfo[modulePath] = moduleInfo
   self.importModuleInfo:remove(  )
   Log.log( Log.Level.Info, __func__, 2669, function (  )
   
      return string.format( "%s complete", modulePath)
   end
    )
   
   return metaInfo, typeId2TypeInfo, moduleInfo
end

function TransUnit:analyzeImport( token )

   local backupScope = self.scope
   self.scope = self.topScope
   local moduleToken = self:getToken(  )
   local modulePath = moduleToken.txt
   local nextToken = moduleToken
   while true do
      nextToken = self:getToken(  )
      if nextToken.txt == "." then
         nextToken = self:getToken(  )
         moduleToken = nextToken
         modulePath = string.format( "%s.%s", modulePath, moduleToken.txt)
      else
       
         break
      end
      
   end
   
   Ast.switchIdProvier( Ast.IdType.Ext )
   local metaInfo, typeId2TypeInfo, moduleInfo = self:processImport( modulePath )
   Ast.switchIdProvier( Ast.IdType.Base )
   self.scope = backupScope
   local assignName = moduleToken
   if nextToken.txt == "as" then
      assignName = self:getSymbolToken( SymbolMode.MustNot_ )
      nextToken = self:getToken(  )
   end
   
   local moduleTypeInfo = _lune.unwrap( typeId2TypeInfo[metaInfo.__moduleTypeId])
   self.importModule2ModuleInfoCurrent[moduleTypeInfo] = moduleInfo:assign( assignName.txt )
   local moduleSymbolKind = _lune.unwrap( Ast.SymbolKind._from( metaInfo.__moduleSymbolKind ))
   self.scope:add( moduleSymbolKind, false, false, assignName.txt, moduleTypeInfo, Ast.AccessMode.Local, true, metaInfo.__moduleMutable and Ast.MutMode.Mut or Ast.MutMode.IMut, true )
   self:checkToken( nextToken, ";" )
   return Nodes.ImportNode.create( self.nodeManager, token.pos, {Ast.builtinTypeNone}, modulePath, assignName.txt, moduleTypeInfo )
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
   
   local usePath = nil
   if moduleName == "" then
      self:addErrMess( token.pos, "illegal subfile" )
   else
    
      if mode.txt == "use" then
         usePath = moduleName
         if frontInterface.searchModule( moduleName ) then
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
   
   return Nodes.SubfileNode.create( self.nodeManager, token.pos, {Ast.builtinTypeNone}, usePath )
end

function TransUnit:analyzeIf( token )

   local nextToken, continueFlag = self:getContinueToken(  )
   if continueFlag and nextToken.txt == "!" then
      return self:analyzeIfUnwrap( token )
   end
   
   self:pushback(  )
   local list = {}
   local ifExp = self:analyzeExp( false, false )
   table.insert( list, Nodes.IfStmtInfo.new(Nodes.IfKind.If, ifExp, self:analyzeBlock( Nodes.BlockKind.If, TentativeMode.Start )) )
   local function checkCond( condExp )
   
      do
         local _switchExp = condExp:get_expType():get_kind()
         if _switchExp == Ast.TypeInfoKind.Nilable or _switchExp == Ast.TypeInfoKind.Stem then
            
         elseif _switchExp == Ast.TypeInfoKind.Prim then
            if not condExp:get_expType():equals( Ast.builtinTypeBool ) then
               self:addErrMess( condExp:get_pos(), string.format( "This exp never be false -- %s", condExp:get_expType():getTxt(  )) )
            end
            
         else 
            
               self:addErrMess( condExp:get_pos(), string.format( "This exp never be false -- %s", condExp:get_expType():getTxt(  )) )
         end
      end
      
   end
   
   checkCond( ifExp )
   nextToken = self:getToken( true )
   if nextToken.txt == "elseif" then
      while nextToken.txt == "elseif" do
         local condExp = self:analyzeExp( false, false )
         table.insert( list, Nodes.IfStmtInfo.new(Nodes.IfKind.ElseIf, condExp, self:analyzeBlock( Nodes.BlockKind.Elseif, TentativeMode.Merge )) )
         checkCond( condExp )
         nextToken = self:getToken( true )
      end
      
   end
   
   if nextToken.txt == "else" then
      table.insert( list, Nodes.IfStmtInfo.new(Nodes.IfKind.Else, self:createNoneNode( nextToken.pos ), self:analyzeBlock( Nodes.BlockKind.Else, TentativeMode.Finish )) )
   else
    
      self:finishTentativeSymbol( false )
      self:pushback(  )
   end
   
   return Nodes.IfNode.create( self.nodeManager, token.pos, {Ast.builtinTypeNone}, list )
end

function TransUnit:analyzeSwitch( firstToken )

   local exp = self:analyzeExp( false, false )
   self:checkNextToken( "{" )
   local caseList = {}
   local nextToken = self:getToken(  )
   local firstFlag = true
   while (nextToken.txt == "case" ) do
      self:checkToken( nextToken, "case" )
      local condexpList = self:analyzeExpList( false, false, nil, {exp:get_expType()}, true )
      local condBock = self:analyzeBlock( Nodes.BlockKind.Switch, firstFlag and TentativeMode.Start or TentativeMode.Merge )
      if firstFlag then
         firstFlag = false
      end
      
      table.insert( caseList, Nodes.CaseInfo.new(condexpList, condBock) )
      nextToken = self:getToken(  )
   end
   
   local defaultBlock = nil
   if nextToken.txt == "default" then
      defaultBlock = self:analyzeBlock( Nodes.BlockKind.Default, firstFlag and TentativeMode.Simple or TentativeMode.Finish )
   else
    
      if not firstFlag then
         self:finishTentativeSymbol( false )
      end
      
      self:pushback(  )
   end
   
   self:checkNextToken( "}" )
   return Nodes.SwitchNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeNone}, exp, caseList, defaultBlock )
end

function TransUnit:analyzeMatch( firstToken )

   local exp = self:analyzeExp( false, false )
   local algeTypeInfo = _lune.__Cast( exp:get_expType():get_srcTypeInfo(), 3, Ast.AlgeTypeInfo )
   if  nil == algeTypeInfo then
      local _algeTypeInfo = algeTypeInfo
   
      self:error( "match must have alge value" )
   end
   
   self:checkNextToken( "{" )
   local caseList = {}
   local nextToken = self:getToken(  )
   local firstFlag = true
   while (nextToken.txt == "case" ) do
      self:checkNextToken( "." )
      local valNameToken = self:getToken(  )
      self:checkAlgeComp( valNameToken, algeTypeInfo )
      local valInfo = algeTypeInfo:getValInfo( valNameToken.txt )
      if  nil == valInfo then
         local _valInfo = valInfo
      
         self:error( string.format( "not found val -- %s", valNameToken.txt) )
      end
      
      local valParamNameList = {}
      nextToken = self:getToken(  )
      local blockScope = self:pushScope( false )
      if nextToken.txt == "(" then
         for __index, paramType in pairs( valInfo:get_typeList() ) do
            local paramName = self:getSymbolToken( SymbolMode.MustNot_ )
            if self.scope:getTypeInfo( paramName.txt, self.scope, true ) then
               self:addErrMess( paramName.pos, string.format( "shadowing variable -- %s", paramName.txt) )
            end
            
            local workType = paramType
            if Ast.TypeInfo.isMut( paramType ) and not Ast.TypeInfo.isMut( exp:get_expType() ) then
               workType = self:createModifier( workType, Ast.MutMode.IMut )
            end
            
            blockScope:addLocalVar( true, false, paramName.txt, workType, Ast.MutMode.IMut )
            table.insert( valParamNameList, paramName.txt )
            nextToken = self:getToken(  )
            if nextToken.txt ~= "," then
               break
            end
            
         end
         
         self:checkToken( nextToken, ")" )
      else
       
         self:pushback(  )
      end
      
      if #valParamNameList ~= #valInfo:get_typeList() then
         self:addErrMess( valNameToken.pos, string.format( "unmatch param -- %d != %d", #valParamNameList, #valInfo:get_typeList()) )
      end
      
      local block = self:analyzeBlock( Nodes.BlockKind.Match, firstFlag and TentativeMode.Start or TentativeMode.Merge, blockScope )
      if firstFlag then
         firstFlag = false
      end
      
      self:popScope(  )
      local matchCase = Nodes.MatchCase.new(valInfo, valParamNameList, block)
      table.insert( caseList, matchCase )
      nextToken = self:getToken(  )
   end
   
   local defaultBlock = nil
   if nextToken.txt == "default" then
      defaultBlock = self:analyzeBlock( Nodes.BlockKind.Block, firstFlag and TentativeMode.Simple or TentativeMode.Finish )
      nextToken = self:getToken(  )
   else
    
      self:finishTentativeSymbol( false )
   end
   
   self:checkToken( nextToken, "}" )
   return Nodes.MatchNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeNone}, exp, algeTypeInfo, caseList, defaultBlock )
end

function TransUnit:analyzeWhile( token )

   return Nodes.WhileNode.create( self.nodeManager, token.pos, {Ast.builtinTypeNone}, self:analyzeExp( false, false ), self:analyzeBlock( Nodes.BlockKind.While, TentativeMode.Loop ) )
end

function TransUnit:analyzeRepeat( token )

   local scope = self:pushScope( false )
   local node = Nodes.RepeatNode.create( self.nodeManager, token.pos, {Ast.builtinTypeNone}, self:analyzeBlock( Nodes.BlockKind.Repeat, TentativeMode.Simple, scope ), self:analyzeExp( false, false ) )
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
   local exp1 = self:analyzeExp( false, false )
   if not Ast.isNumberType( exp1:get_expType() ) then
      self:addErrMess( exp1:get_pos(), string.format( "exp1 is not number -- %s", exp1:get_expType():getTxt(  )) )
   end
   
   local symbolInfo = self:addLocalVar( exp1:get_pos(), false, true, val.txt, exp1:get_expType(), Ast.MutMode.IMut )
   self:checkNextToken( "," )
   local exp2 = self:analyzeExp( false, false )
   if not Ast.isNumberType( exp2:get_expType() ) then
      self:addErrMess( exp2:get_pos(), string.format( "exp2 is not number -- %s", exp2:get_expType():getTxt(  )) )
   end
   
   local token = self:getToken(  )
   local exp3 = nil
   if token.txt == "," then
      exp3 = self:analyzeExp( false, false )
      do
         local _exp = exp3
         if _exp ~= nil then
            if not Ast.isNumberType( _exp:get_expType() ) then
               self:addErrMess( _exp:get_pos(), string.format( "exp is not number -- %s", _exp:get_expType():getTxt(  )) )
            end
            
         end
      end
      
   else
    
      self:pushback(  )
   end
   
   local node = Nodes.ForNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeNone}, self:analyzeBlock( Nodes.BlockKind.For, TentativeMode.Loop, scope ), symbolInfo, exp1, exp2, exp3 )
   self:popScope(  )
   return node
end

function TransUnit:analyzeApply( token )

   local scope = self:pushScope( false )
   local varList = {}
   local nextToken = Parser.getEofToken(  )
   repeat 
      local var = self:getSymbolToken( SymbolMode.MustNot_ )
      if var.kind ~= Parser.TokenKind.Symb then
         self:error( "illegal symbol" )
      end
      
      table.insert( varList, var )
      nextToken = self:getToken(  )
   until nextToken.txt ~= ","
   self:checkToken( nextToken, "of" )
   local exp = self:analyzeExp( false, false )
   local expTypeList = exp:get_expTypeList()
   if #expTypeList < 3 then
      self:addErrMess( exp:get_pos(), string.format( "apply must have 3 values -- %s", tostring( #expTypeList)) )
   end
   
   local itemTypeList = {}
   local defaultItemType = Ast.builtinTypeStem_
   do
      local callNode = _lune.__Cast( exp, 3, Nodes.ExpCallNode )
      if callNode ~= nil then
         local callFuncType = callNode:get_func():get_expType()
         if callFuncType:equals( builtinFunc.str_gmatch ) or callFuncType:equals( builtinFunc.string_gmatch ) then
            table.insert( itemTypeList, Ast.builtinTypeString )
            defaultItemType = Ast.builtinTypeString:get_nilableTypeInfo()
         else
          
            if #callFuncType:get_retTypeInfoList() == 0 then
               self:addErrMess( exp:get_pos(), "apply value must return iterator function." )
            end
            
            local iteFunc = callFuncType:get_retTypeInfoList()[1]
            for index, itemType in pairs( iteFunc:get_retTypeInfoList() ) do
               local workType = itemType
               if index == 1 then
                  if itemType:get_nilable() then
                     workType = workType:get_nonnilableType()
                  end
                  
               end
               
               table.insert( itemTypeList, workType )
            end
            
         end
         
      end
   end
   
   for index, var in pairs( varList ) do
      local itemType = defaultItemType
      if index <= #itemTypeList then
         itemType = itemTypeList[index]
      end
      
      self:addLocalVar( var.pos, false, true, var.txt, itemType, Ast.MutMode.IMut )
   end
   
   local block = self:analyzeBlock( Nodes.BlockKind.Apply, TentativeMode.Loop, scope )
   self:popScope(  )
   return Nodes.ApplyNode.create( self.nodeManager, token.pos, {Ast.builtinTypeNone}, varList, exp, block )
end

function TransUnit:analyzeForeach( token, sortFlag )

   local scope = self:pushScope( false )
   local mainSymbol = Parser.getEofToken(  )
   local valSymbol = nil
   local subSymbol = nil
   local nextToken = Parser.getEofToken(  )
   for index = 1, 2 do
      local symbol = self:getToken(  )
      if symbol.kind ~= Parser.TokenKind.Symb then
         self:error( "illegal symbol" )
      end
      
      if index == 1 then
         mainSymbol = symbol
         valSymbol = symbol
      else
       
         subSymbol = symbol
      end
      
      nextToken = self:getToken(  )
      if nextToken.txt ~= "," then
         break
      end
      
   end
   
   self:checkToken( nextToken, "in" )
   local exp = self:analyzeExp( false, false )
   local itemTypeInfoList = exp:get_expType():get_itemTypeInfoList(  )
   if exp:get_expType():get_kind(  ) == Ast.TypeInfoKind.Map then
      self:addLocalVar( exp:get_pos(), true, true, mainSymbol.txt, itemTypeInfoList[2], Ast.MutMode.IMut )
      do
         local _exp = subSymbol
         if _exp ~= nil then
            self:addLocalVar( _exp.pos, true, true, _exp.txt, itemTypeInfoList[1], Ast.MutMode.IMut )
         end
      end
      
   elseif exp:get_expType():get_kind(  ) == Ast.TypeInfoKind.Set then
      if subSymbol ~= nil then
         self:addErrMess( subSymbol.pos, "Set can't use index" )
      end
      
      valSymbol = nil
      subSymbol = mainSymbol
      self.scope:addLocalVar( true, true, mainSymbol.txt, itemTypeInfoList[1], Ast.MutMode.IMut )
   elseif exp:get_expType():get_kind(  ) == Ast.TypeInfoKind.List or exp:get_expType():get_kind(  ) == Ast.TypeInfoKind.Array then
      if sortFlag then
         self:addErrMess( exp:get_pos(), string.format( "'%s' doesn't support forsort.", Ast.TypeInfoKind:_getTxt( exp:get_expType():get_kind(  ))
         ) )
      end
      
      self.scope:addLocalVar( true, true, mainSymbol.txt, itemTypeInfoList[1], Ast.MutMode.IMut )
      do
         local _exp = subSymbol
         if _exp ~= nil then
            self:addLocalVar( _exp.pos, true, false, _exp.txt, Ast.builtinTypeInt, Ast.MutMode.IMut )
         else
            self.scope:addLocalVar( true, false, "__index", Ast.builtinTypeInt, Ast.MutMode.IMut )
         end
      end
      
   else
    
      self:error( string.format( "unknown kind type of exp for foreach-- %s(%d:%d)", exp:get_expType():getTxt(  ), exp:get_pos().lineNo, exp:get_pos().column) )
   end
   
   local seqSym = nil
   do
      local refNode = _lune.__Cast( exp, 3, Nodes.ExpRefNode )
      if refNode ~= nil then
         local seqSymbol = refNode:get_symbolInfo()
         if seqSymbol:get_mutable() or Ast.TypeInfo.isMut( seqSymbol:get_typeInfo() ) then
            local typeInfo
            
            if Ast.TypeInfo.isMut( seqSymbol:get_typeInfo() ) then
               typeInfo = self:createModifier( seqSymbol:get_typeInfo(), Ast.MutMode.IMut )
            else
             
               typeInfo = seqSymbol:get_typeInfo()
            end
            
            scope:addLocalVar( seqSymbol:get_kind() == Ast.SymbolKind.Arg, false, seqSymbol:get_name(), typeInfo, Ast.MutMode.IMut )
            seqSym = seqSymbol:get_name()
         end
         
      end
   end
   
   local block = self:analyzeBlock( Nodes.BlockKind.Foreach, TentativeMode.Loop, scope )
   if seqSym ~= nil then
      scope:remove( seqSym )
   end
   
   self:popScope(  )
   if sortFlag then
      return Nodes.ForsortNode.create( self.nodeManager, token.pos, {Ast.builtinTypeNone}, mainSymbol, subSymbol, exp, block, sortFlag )
   else
    
      return Nodes.ForeachNode.create( self.nodeManager, token.pos, {Ast.builtinTypeNone}, valSymbol, subSymbol, exp, block )
   end
   
end

function TransUnit:analyzeProvide( firstToken )

   local token = self:getSymbolToken( SymbolMode.MustNot_ )
   local symbolNode = self:analyzeExpSymbol( firstToken, token, ExpSymbolMode.Symbol, nil, true )
   self:checkNextToken( ";" )
   local symbolInfoList = symbolNode:getSymbolInfo(  )
   if #symbolInfoList ~= 1 then
      self:error( "'provide' must be symbol." )
   end
   
   local symbolInfo = symbolInfoList[1]
   local node = Nodes.ProvideNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeNone}, symbolInfo )
   if self.provideNode then
      self:addErrMess( firstToken.pos, "multiple provide" )
   end
   
   self.provideNode = node
   if symbolInfo:get_accessMode() ~= Ast.AccessMode.Pub then
      self:addErrMess( firstToken.pos, string.format( "provide variable must be 'pub'.  -- %s", tostring( symbolInfo:get_accessMode())) )
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
   
   self:checkSymbol( token, SymbolMode.MustNot_ )
   local name = self:analyzeExpSymbol( firstToken, token, ExpSymbolMode.Symbol, nil, true )
   return self:analyzeRefTypeWithSymbol( accessMode, allowDDD, refFlag, mutFlag, name )
end

function TransUnit:analyzeRefTypeWithSymbol( accessMode, allowDDD, refFlag, mutFlag, symbolNode )

   local typeInfo = symbolNode:get_expType()
   local continueToken, continueFlag = self:getContinueToken(  )
   local token = continueToken
   if continueFlag and token.txt == "!" then
      typeInfo = typeInfo:get_nilableTypeInfo(  )
      token = self:getToken(  )
   end
   
   local arrayMode = "no"
   while true do
      if token.txt == '[' or token.txt == '[@' then
         if token.txt == '[' then
            arrayMode = "list"
            typeInfo = Ast.NormalTypeInfo.createList( accessMode, self:getCurrentClass(  ), {typeInfo}, Ast.MutMode.Mut )
         else
          
            arrayMode = "array"
            typeInfo = Ast.NormalTypeInfo.createArray( accessMode, self:getCurrentClass(  ), {typeInfo}, Ast.MutMode.Mut )
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
         local function checkAlternateTypeCount( count )
         
            if #genericList ~= count then
               self:addErrMess( symbolNode:get_pos(), string.format( "generic type count is unmatch. -- %d", #genericList) )
               return false
            end
            
            return true
         end
         
         do
            local _switchExp = typeInfo:get_kind()
            if _switchExp == Ast.TypeInfoKind.Map then
               if #genericList < 2 then
                  self:addErrMess( symbolNode:get_pos(), "Key or value type is unknown" )
                  typeInfo = Ast.NormalTypeInfo.createMap( accessMode, self:getCurrentClass(  ), Ast.builtinTypeStem, Ast.builtinTypeStem, Ast.MutMode.Mut )
               else
                
                  typeInfo = Ast.NormalTypeInfo.createMap( accessMode, self:getCurrentClass(  ), genericList[1], genericList[2], Ast.MutMode.Mut )
               end
               
            elseif _switchExp == Ast.TypeInfoKind.List then
               if checkAlternateTypeCount( 1 ) then
                  typeInfo = Ast.NormalTypeInfo.createList( accessMode, self:getCurrentClass(  ), {genericList[1] or Ast.builtinTypeStem}, Ast.MutMode.Mut )
               end
               
            elseif _switchExp == Ast.TypeInfoKind.Array then
               if checkAlternateTypeCount( 1 ) then
                  typeInfo = Ast.NormalTypeInfo.createArray( accessMode, self:getCurrentClass(  ), {genericList[1] or Ast.builtinTypeStem}, Ast.MutMode.Mut )
               end
               
            elseif _switchExp == Ast.TypeInfoKind.Set then
               if checkAlternateTypeCount( 1 ) then
                  typeInfo = Ast.NormalTypeInfo.createSet( accessMode, self:getCurrentClass(  ), {genericList[1] or Ast.builtinTypeStem}, Ast.MutMode.Mut )
               end
               
            elseif _switchExp == Ast.TypeInfoKind.DDD then
               if checkAlternateTypeCount( 1 ) then
                  typeInfo = Ast.NormalTypeInfo.createDDD( genericList[1], false )
               end
               
            elseif _switchExp == Ast.TypeInfoKind.Class or _switchExp == Ast.TypeInfoKind.IF then
               if checkAlternateTypeCount( #typeInfo:get_itemTypeInfoList() ) then
                  for index, itemType in pairs( genericList ) do
                     local altType = _lune.unwrap( _lune.__Cast( typeInfo:get_itemTypeInfoList()[index], 3, Ast.AlternateTypeInfo ))
                     if itemType:get_nilable() then
                        self:addErrMess( symbolNode:get_pos(), string.format( "can't use nilable type -- %s", itemType:getTxt(  )) )
                     end
                     
                  end
                  
                  typeInfo = Ast.NormalTypeInfo.createGeneric( typeInfo, genericList, self.moduleType )
               end
               
            elseif _switchExp == Ast.TypeInfoKind.Box then
               if checkAlternateTypeCount( 1 ) then
                  typeInfo = Ast.NormalTypeInfo.createBox( accessMode, genericList[1] )
               end
               
            else 
               
                  self:error( string.format( "not support generic: %s", typeInfo:getTxt(  ) ) )
            end
         end
         
      else
       
         self:pushback(  )
         break
      end
      
      token = self:getToken(  )
   end
   
   if token.txt == "!" then
      typeInfo = typeInfo:get_nilableTypeInfo(  )
      token = self:getToken(  )
   end
   
   if not allowDDD then
      if typeInfo:get_kind() == Ast.TypeInfoKind.DDD then
         self:addErrMess( symbolNode:get_pos(), string.format( "invalid type. -- '%s'", typeInfo:getTxt(  )) )
      end
      
   end
   
   if refFlag then
      typeInfo = self:createModifier( typeInfo, Ast.MutMode.IMut )
   end
   
   return Nodes.RefTypeNode.create( self.nodeManager, symbolNode:get_pos(), {typeInfo}, symbolNode, refFlag, mutFlag, arrayMode )
end

function TransUnit:analyzeDeclArgList( accessMode, argList )

   local nextToken = Parser.noneToken
   local hasDDDFlag = false
   repeat 
      nextToken = self:getToken(  )
      if nextToken.txt == ")" then
         break
      end
      
      if hasDDDFlag then
         self:addErrMess( nextToken.pos, "Argument exists after '...'." )
      end
      
      local mutable = Ast.MutMode.IMut
      if nextToken.txt == "mut" then
         mutable = Ast.MutMode.Mut
         nextToken = self:getToken(  )
      end
      
      local argName = nextToken
      if argName.txt == "..." then
         hasDDDFlag = true
         local workToken, flag = self:getContinueToken(  )
         self:pushback(  )
         local dddTypeInfo = Ast.builtinTypeDDD
         if flag and workToken.txt == "<" then
            self:pushbackToken( nextToken )
            local refTypeNode = self:analyzeRefType( accessMode, true )
            dddTypeInfo = refTypeNode:get_expType()
         end
         
         table.insert( argList, Nodes.DeclArgDDDNode.create( self.nodeManager, argName.pos, {dddTypeInfo} ) )
         self.scope:addLocalVar( true, true, argName.txt, dddTypeInfo, Ast.MutMode.IMut )
      else
       
         argName = self:checkSymbol( argName, SymbolMode.MustNot_ )
         if self.scope:getSymbolTypeInfo( argName.txt, self.scope, self.moduleScope ) then
            self:addErrMess( argName.pos, string.format( "shadowing variable -- %s", argName.txt) )
         end
         
         self:checkNextToken( ":" )
         local refType = self:analyzeRefType( accessMode, false )
         local arg = Nodes.DeclArgNode.create( self.nodeManager, argName.pos, refType:get_expTypeList(), argName, refType )
         self.scope:addLocalVar( true, true, argName.txt, refType:get_expType(), mutable )
         table.insert( argList, arg )
      end
      
      nextToken = self:getToken(  )
   until nextToken.txt ~= ","
   self:checkToken( nextToken, ")" )
   return nextToken
end

function TransUnit:checkOverriededMethod(  )

   local function checkOverrideMethodSub( pos, alt2typeMap, classScope, scope )
   
      scope:filterTypeInfoField( true, classScope, function ( symbolInfo )
      
         if symbolInfo:get_name() == "__init" then
            return true
         end
         
         if symbolInfo:get_typeInfo():get_kind() == Ast.TypeInfoKind.Method then
            local noImp = false
            do
               local impMethodType = classScope:getTypeInfoField( symbolInfo:get_name(), true, classScope )
               if impMethodType ~= nil then
                  if not impMethodType:canEvalWith( symbolInfo:get_typeInfo(), Ast.CanEvalType.SetOp, alt2typeMap ) then
                     self:addErrMess( pos, string.format( "mismatch method -- %s %s", symbolInfo:get_typeInfo():get_display_stirng(), impMethodType:get_display_stirng()) )
                  end
                  
                  if impMethodType:get_abstractFlag() then
                     noImp = true
                  end
                  
               else
                  noImp = true
               end
            end
            
            if noImp then
               self:addErrMess( pos, "not implements method -- " .. symbolInfo:get_name() )
            end
            
         end
         
         return true
      end
       )
   end
   
   local typeId2DeclClassNode = {}
   for classTypeInfo, classNode in pairs( self.typeInfo2ClassNode ) do
      typeId2DeclClassNode[classTypeInfo:get_typeId()] = classNode
   end
   
   do
      local __sorted = {}
      local __map = typeId2DeclClassNode
      for __key in pairs( __map ) do
         table.insert( __sorted, __key )
      end
      table.sort( __sorted )
      for __index, __key in ipairs( __sorted ) do
         local classNode = __map[ __key ]
         do
            local classTypeInfo = classNode:get_expType()
            if not classTypeInfo:get_abstractFlag() then
               local workTypeInfo = classTypeInfo
               local alt2typeMap = classTypeInfo:createAlt2typeMap( false )
               repeat 
                  if workTypeInfo ~= Ast.headTypeInfo then
                     checkOverrideMethodSub( classNode:get_pos(), alt2typeMap, _lune.unwrap( classTypeInfo:get_scope()), _lune.unwrap( workTypeInfo:get_scope()) )
                  end
                  
                  for __index, ifType in pairs( workTypeInfo:get_interfaceList() ) do
                     if ifType ~= Ast.builtinTypeMapping then
                        checkOverrideMethodSub( classNode:get_pos(), alt2typeMap, _lune.unwrap( classTypeInfo:get_scope()), _lune.unwrap( ifType:get_scope()) )
                     end
                     
                  end
                  
                  workTypeInfo = workTypeInfo:get_baseTypeInfo()
               until workTypeInfo == Ast.headTypeInfo
            end
            
         end
      end
   end
   
end

local ASTInfo = {}
_moduleObj.ASTInfo = ASTInfo
function ASTInfo.setmeta( obj )
  setmetatable( obj, { __index = ASTInfo  } )
end
function ASTInfo.new( node, moduleTypeInfo, moduleSymbolKind )
   local obj = {}
   ASTInfo.setmeta( obj )
   if obj.__init then
      obj:__init( node, moduleTypeInfo, moduleSymbolKind )
   end
   return obj
end
function ASTInfo:__init( node, moduleTypeInfo, moduleSymbolKind )

   self.node = node
   self.moduleTypeInfo = moduleTypeInfo
   self.moduleSymbolKind = moduleSymbolKind
end
function ASTInfo:get_node()
   return self.node
end
function ASTInfo:get_moduleTypeInfo()
   return self.moduleTypeInfo
end
function ASTInfo:get_moduleSymbolKind()
   return self.moduleSymbolKind
end

function TransUnit:createAST( parser, macroFlag, moduleName )

   self.moduleName = _lune.unwrapDefault( moduleName, "")
   self:registBuiltInScope(  )
   local processInfo = Ast.pushProcessInfo(  )
   local moduleTypeInfo = Ast.headTypeInfo
   local moduleSymbolKind = Ast.SymbolKind.Typ
   if moduleName ~= nil then
      for txt in string.gmatch( moduleName, '[^%.]+' ) do
         moduleTypeInfo = self:pushModule( false, txt, true )
      end
      
   end
   
   self.moduleScope = self.scope
   self.moduleType = moduleTypeInfo
   self.parser = parser
   local ast
   
   local lastStatement = nil
   if macroFlag then
      ast = self:analyzeBlock( Nodes.BlockKind.Macro, TentativeMode.Ignore )
   else
    
      local children = {}
      lastStatement = self:analyzeStatementList( children )
      local token = self:getTokenNoErr(  )
      if token ~= Parser.getEofToken(  ) then
         self:error( string.format( "%s:%d:%d:(%s) not eof -- %s", self.parser:getStreamName(  ), token.pos.lineNo, token.pos.column, Parser.TokenKind:_getTxt( token.kind)
         , token.txt) )
      end
      
      for __index, subModule in pairs( self.subfileList ) do
         local file = frontInterface.searchModule( subModule )
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
            Util.err( string.format( "unknown:%d:%d:(%s) %s", token.pos.lineNo, token.pos.column, Parser.TokenKind:_getTxt( token.kind)
            , token.txt) )
         end
         
      end
      
      self:checkOverriededMethod(  )
      local rootNode = Nodes.RootNode.create( self.nodeManager, Parser.Position.new(0, 0), {Ast.builtinTypeNone}, children, self.moduleScope, self.useModuleMacroSet, self.moduleId, processInfo, moduleTypeInfo, nil, self.helperInfo, self.nodeManager, self.importModule2ModuleInfo, self.typeId2MacroInfo, self.typeId2ClassMap )
      ast = rootNode
      do
         local _exp = self.provideNode
         if _exp ~= nil then
            if lastStatement ~= _exp then
               self:addErrMess( _exp:get_pos(), "'provide' must be last." )
            end
            
            rootNode:set_provide( _exp )
            moduleSymbolKind = _exp:get_symbol():get_kind()
         end
      end
      
   end
   
   if moduleName ~= nil then
      for txt in string.gmatch( moduleName, '[^%.]+' ) do
         self:popModule(  )
      end
      
   end
   
   Ast.popProcessInfo(  )
   for protoType, pos in pairs( self.protoFuncMap ) do
      self:addErrMess( pos, string.format( "This function doesn't have body. -- %s", protoType:getTxt(  )) )
   end
   
   for protoType, pos in pairs( self.protoClassMap ) do
      self:addErrMess( pos, string.format( "This class doesn't have body. -- %s", protoType:getTxt(  )) )
   end
   
   for __index, mess in pairs( self.warnMessList ) do
      Util.errorLog( mess )
   end
   
   if #self.errMessList > 0 then
      for __index, mess in pairs( self.errMessList ) do
         Util.errorLog( mess )
      end
      
      Util.err( "has error" )
   end
   
   if self.ctrl_info.stopByWarning and #self.warnMessList > 0 then
      Util.err( "has error" )
   end
   
   if self.analyzeMode == AnalyzeMode.Diag or self.analyzeMode == AnalyzeMode.Complete then
      os.exit( 0 )
   end
   
   return ASTInfo.new(ast, moduleTypeInfo, moduleSymbolKind)
end

function TransUnit:analyzeDeclMacro( accessMode, firstToken )

   local pubFlag = false
   do
      local _switchExp = accessMode
      if _switchExp == Ast.AccessMode.Pub then
         pubFlag = true
      elseif _switchExp == Ast.AccessMode.Local or _switchExp == Ast.AccessMode.None then
      else 
         
            self:addErrMess( firstToken.pos, string.format( "macro not support this access mode. -- %s", Ast.AccessMode:_getTxt( accessMode)
            ) )
      end
   end
   
   local nameToken = self:getSymbolToken( SymbolMode.Must_ )
   self:checkNextToken( "(" )
   local scope = self:pushScope( false )
   local workArgList = {}
   local argList = {}
   local nextToken = self:analyzeDeclArgList( accessMode, workArgList )
   local argTypeList = {}
   for index, argNode in pairs( workArgList ) do
      do
         local _exp = _lune.__Cast( argNode, 3, Nodes.DeclArgNode )
         if _exp ~= nil then
            table.insert( argList, _exp )
         else
            self:error( "macro argument can not use '...'." )
         end
      end
      
      local argType = argNode:get_expType()
      table.insert( argTypeList, argType )
   end
   
   self:checkNextToken( "{" )
   nextToken = self:getToken(  )
   local stmtBlock = nil
   if nextToken.txt == "{" then
      local parser = Parser.WrapParser.new(self.parser, string.format( "decl macro %s", nameToken.txt))
      self.macroScope = scope
      local funcType = Ast.NormalTypeInfo.createFunc( false, true, nil, Ast.TypeInfoKind.Func, Ast.headTypeInfo, false, true, true, Ast.AccessMode.Global, "_lnsLoad", nil, {Ast.builtinTypeString, Ast.builtinTypeString}, {Ast.builtinTypeStem}, false )
      scope:addLocalVar( false, false, "_lnsLoad", funcType, Ast.MutMode.IMut )
      local bakParser = self.parser
      self.parser = parser
      local stmtList = {}
      self:prepareTentativeSymbol( self.scope, false )
      self:analyzeStatementList( stmtList, "}" )
      self:checkNextToken( "}" )
      self:finishTentativeSymbol( false )
      self.parser = bakParser
      self.macroScope = nil
      stmtBlock = Nodes.BlockNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeNone}, Nodes.BlockKind.Macro, scope, stmtList )
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
   
   local typeInfo = Ast.NormalTypeInfo.createFunc( false, false, scope, Ast.TypeInfoKind.Macro, self:getCurrentNamespaceTypeInfo(  ), false, false, true, accessMode, nameToken.txt, nil, argTypeList )
   self.scope:addMacro( typeInfo, accessMode )
   local declMacroInfo = Nodes.DeclMacroInfo.new(pubFlag, nameToken, argList, stmtBlock, tokenList)
   local node = Nodes.DeclMacroNode.create( self.nodeManager, firstToken.pos, {typeInfo}, declMacroInfo )
   local macroObj = self.macroEval:eval( node )
   self.typeId2MacroInfo[typeInfo:get_typeId(  )] = Nodes.DefMacroInfo.new(macroObj, declMacroInfo, self.symbol2ValueMapForMacro)
   self.symbol2ValueMapForMacro = {}
   return node
end

function TransUnit:analyzeExtend( accessMode, firstPos )

   local baseRef = nil
   local interfaceList = {}
   local ifAlt2typeMap = {}
   local nextToken = self:getToken(  )
   if nextToken.txt ~= "(" then
      self:pushback(  )
      local workBaseRefType = self:analyzeRefType( accessMode, false )
      baseRef = workBaseRefType
      local baseType = workBaseRefType:get_expType()
      if baseType:get_kind() ~= Ast.TypeInfoKind.Class then
         self:addErrMess( workBaseRefType:get_pos(), string.format( "%s is not class.", baseType:getTxt(  )) )
      end
      
      if Ast.isPubToExternal( accessMode ) and not Ast.isPubToExternal( baseType:get_accessMode() ) then
         self:addErrMess( workBaseRefType:get_pos(), string.format( "%s can't be external symbol.", baseType:getTxt(  )) )
      end
      
      nextToken = self:getToken(  )
   end
   
   if nextToken.txt == "(" then
      while true do
         nextToken = self:getToken(  )
         if nextToken.txt == ")" then
            break
         end
         
         self:pushback(  )
         local ifTypeNode = self:analyzeRefType( accessMode, false )
         local ifType = ifTypeNode:get_expType()
         if ifType:get_kind() ~= Ast.TypeInfoKind.IF then
            self:error( string.format( "%s is not interface -- %d", ifType:getTxt(  ), ifType:get_kind()) )
         end
         
         if Ast.isGenericType( ifType ) then
            for altType, genType in pairs( ifType:createAlt2typeMap( false ) ) do
               ifAlt2typeMap[altType] = genType
            end
            
         end
         
         table.insert( interfaceList, ifType )
         if Ast.isPubToExternal( accessMode ) and not Ast.isPubToExternal( ifType:get_accessMode() ) then
            self:addErrMess( ifTypeNode:get_pos(), string.format( "%s can't be external symbol.", ifType:getTxt(  )) )
         end
         
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
   
   local symbol2TypeInfo = {}
   for __index, ifType in pairs( interfaceList ) do
      _lune.nilacc( ifType:get_scope(), 'filterTypeInfoField', 'callmtd' , true, self.scope, function ( symbolInfo )
      
         do
            local ifFuncType = symbol2TypeInfo[symbolInfo:get_name()]
            if ifFuncType ~= nil then
               if not ifFuncType:canEvalWith( symbolInfo:get_typeInfo(), Ast.CanEvalType.SetOp, ifAlt2typeMap ) then
                  self:addErrMess( firstPos, string.format( "mismatch method type -- %s.%s, %s.%s", symbolInfo:get_typeInfo():get_parentInfo():getTxt(  ), symbolInfo:get_name(), ifFuncType:get_parentInfo():getTxt(  ), ifFuncType:getTxt(  )) )
               end
               
            else
               symbol2TypeInfo[symbolInfo:get_name()] = symbolInfo:get_typeInfo()
            end
         end
         
         return true
      end
       )
   end
   
   local baseTypeInfo = nil
   if baseRef ~= nil then
      baseTypeInfo = baseRef:get_expType()
   end
   
   return nextToken, baseTypeInfo, interfaceList, ifAlt2typeMap
end

function TransUnit:analyzePushClass( classFlag, abstractFlag, firstToken, name, accessMode, altTypeList )

   if classFlag and Ast.isPubToExternal( accessMode ) and self.moduleScope ~= self.scope then
      self:addErrMess( firstToken.pos, "The public class must declare at top scope." )
   end
   
   local tempScope = self:pushScope( false )
   for __index, altType in pairs( altTypeList ) do
      tempScope:addAlternate( accessMode, altType:get_rawTxt(), altType )
   end
   
   local nextToken = self:getToken(  )
   local baseTypeInfo = nil
   local interfaceList = {}
   if nextToken.txt == "extend" then
      nextToken, baseTypeInfo, interfaceList = self:analyzeExtend( accessMode, firstToken.pos )
      if baseTypeInfo ~= nil then
         do
            local initTypeInfo = _lune.nilacc( baseTypeInfo:get_scope(), 'getTypeInfoChild', 'callmtd' , "__init" )
            if initTypeInfo ~= nil then
               if initTypeInfo:get_accessMode() == Ast.AccessMode.Pri then
                  self:addErrMess( firstToken.pos, "The access mode of '__init' is 'pri'." )
               end
               
            end
         end
         
         
      end
      
   end
   
   self:popScope(  )
   local classTypeInfo = self:pushClass( classFlag, abstractFlag, baseTypeInfo, interfaceList, altTypeList, false, name.txt, accessMode )
   return nextToken, classTypeInfo
end

function TransUnit:analyzeDeclAlternateType( belongClassFlag, token, accessMode )

   local altTypeList = {}
   local nextToken = token
   local altNameSet = {}
   local altIndex = 0
   while true do
      altIndex = altIndex + 1
      local genericSymToken = self:getSymbolToken( SymbolMode.MustNot_ )
      if self.scope:getTypeInfo( genericSymToken.txt, self.scope, true ) then
         self:addErrMess( genericSymToken.pos, string.format( "shadowing Type -- %s", genericSymToken.txt) )
      else
       
         if _lune._Set_has(altNameSet, genericSymToken.txt ) then
            self:addErrMess( genericSymToken.pos, string.format( "multiple Type -- %s", genericSymToken.txt) )
         else
          
            altNameSet[genericSymToken.txt]= true
         end
         
      end
      
      local workToken = self:getToken(  )
      if workToken.txt == "!" then
         self:addErrMess( workToken.pos, "not support nilable" )
         workToken = self:getToken(  )
      end
      
      local baseTypeInfo = nil
      local interfaceList = {}
      if workToken.txt == ":" then
         workToken, baseTypeInfo, interfaceList = self:analyzeExtend( accessMode, token.pos )
      end
      
      local altType = Ast.NormalTypeInfo.createAlternate( belongClassFlag, altIndex, genericSymToken.txt, accessMode, self.moduleType, baseTypeInfo, interfaceList )
      table.insert( altTypeList, altType )
      if workToken.txt == ">" then
         nextToken = self:getToken(  )
         break
      end
      
      self:checkToken( workToken, "," )
   end
   
   return nextToken, altTypeList
end

function TransUnit:analyzeDeclProto( accessMode, firstToken )

   local nextToken = self:getToken(  )
   local abstractFlag = false
   if nextToken.txt == "abstract" then
      abstractFlag = true
      nextToken = self:getToken(  )
   end
   
   if nextToken.txt == "class" or nextToken.txt == "interface" then
      local name = self:getSymbolToken( SymbolMode.MustNot_ )
      local altTypeList = {}
      do
         local workToken = self:getToken(  )
         if workToken.txt == "<" then
            workToken, altTypeList = self:analyzeDeclAlternateType( true, workToken, accessMode )
         end
         
         self:pushbackToken( workToken )
      end
      
      if accessMode == Ast.AccessMode.Local then
         accessMode = Ast.AccessMode.Pri
      end
      
      local classTypeInfo
      
      nextToken, classTypeInfo = self:analyzePushClass( nextToken.txt ~= "interface", abstractFlag, firstToken, name, accessMode, altTypeList )
      self.protoClassMap[classTypeInfo] = firstToken.pos
      self:popClass(  )
      self:checkToken( nextToken, ";" )
   else
    
      self:error( "illegal proto" )
   end
   
   return self:createNoneNode( firstToken.pos )
end

function TransUnit:analyzeDeclEnum( accessMode, firstToken )

   local name = self:getSymbolToken( SymbolMode.MustNot_ )
   self:checkNextToken( "{" )
   local valueList = {}
   local valueName2Info = {}
   local scope = self:pushScope( true )
   local enumTypeInfo = nil
   local nextToken = self:getToken(  )
   local number = 0.0
   local prevValTypeInfo = Ast.headTypeInfo
   local valTypeInfo = Ast.headTypeInfo
   while nextToken.txt ~= "}" do
      local valName = self:checkSymbol( nextToken, SymbolMode.MustNot_ )
      nextToken = self:getToken(  )
      local enumVal = _lune.newAlge( Ast.EnumLiteral.Real, {number})
      do
         local _switchExp = (prevValTypeInfo )
         if _switchExp == Ast.builtinTypeReal then
         elseif _switchExp == Ast.builtinTypeInt or _switchExp == Ast.headTypeInfo then
            enumVal = _lune.newAlge( Ast.EnumLiteral.Int, {math.floor(number)})
         end
      end
      
      if nextToken.txt == "=" then
         local exp = self:analyzeExp( false, false )
         local literal = exp:getLiteral(  )
         if  nil == literal then
            local _literal = literal
         
            self:error( "illegal enum val" )
         end
         
         do
            local _matchExp = literal
            if _matchExp[1] == Nodes.Literal.Int[1] then
               local val = _matchExp[2][1]
            
               enumVal = _lune.newAlge( Ast.EnumLiteral.Int, {val})
               number = val * 1.0
               valTypeInfo = Ast.builtinTypeInt
            elseif _matchExp[1] == Nodes.Literal.Real[1] then
               local val = _matchExp[2][1]
            
               enumVal = _lune.newAlge( Ast.EnumLiteral.Real, {val})
               number = val
               valTypeInfo = Ast.builtinTypeReal
            elseif _matchExp[1] == Nodes.Literal.Str[1] then
               local val = _matchExp[2][1]
            
               enumVal = _lune.newAlge( Ast.EnumLiteral.Str, {val})
               valTypeInfo = Ast.builtinTypeString
            else 
            do
               self:error( string.format( "illegal enum val -- %s", Nodes.Literal:_getTxt( literal)
               ) )
            end
            end
         end
         
         nextToken = self:getToken(  )
      else
       
         do
            local _switchExp = (prevValTypeInfo )
            if _switchExp == Ast.headTypeInfo then
               valTypeInfo = Ast.builtinTypeInt
            elseif _switchExp == Ast.builtinTypeInt or _switchExp == Ast.builtinTypeReal then
               valTypeInfo = prevValTypeInfo
            else 
               
                  self:addErrMess( valName.pos, string.format( "illegal enum val type -- %s", valTypeInfo:getTxt(  )) )
            end
         end
         
      end
      
      if prevValTypeInfo ~= Ast.headTypeInfo and prevValTypeInfo ~= valTypeInfo then
         self:addErrMess( valName.pos, string.format( "multiple enum val type. %s, %s", valTypeInfo:getTxt(  ), prevValTypeInfo:getTxt(  )) )
      end
      
      prevValTypeInfo = valTypeInfo
      if not enumTypeInfo then
         enumTypeInfo = Ast.NormalTypeInfo.createEnum( scope, self:getCurrentNamespaceTypeInfo(  ), false, accessMode, name.txt, valTypeInfo )
      end
      
      if enumTypeInfo ~= nil then
         scope:addEnumVal( valName.txt, enumTypeInfo )
         local enumValInfo = Ast.EnumValInfo.new(valName.txt, enumVal)
         table.insert( valueList, valName )
         enumTypeInfo:addEnumValInfo( enumValInfo )
      end
      
      if nextToken.txt == "}" then
         break
      end
      
      self:checkToken( nextToken, "," )
      nextToken = self:getToken(  )
      number = number + 1
   end
   
   if not enumTypeInfo then
      enumTypeInfo = Ast.NormalTypeInfo.createEnum( scope, self:getCurrentNamespaceTypeInfo(  ), false, accessMode, name.txt, Ast.builtinTypeNone )
   end
   
   self:popScope(  )
   self.scope:addEnum( accessMode, name.txt, _lune.unwrap( enumTypeInfo) )
   return Nodes.DeclEnumNode.create( self.nodeManager, firstToken.pos, {_lune.unwrap( enumTypeInfo)}, accessMode, name, valueList, scope )
end

function TransUnit:analyzeDeclAlge( accessMode, firstToken )

   self.helperInfo.useAlge = true
   local name = self:getSymbolToken( SymbolMode.MustNot_ )
   self:checkNextToken( "{" )
   local scope = self.scope
   local algeScope = self:pushScope( true )
   local algeTypeInfo = Ast.NormalTypeInfo.createAlge( algeScope, self:getCurrentNamespaceTypeInfo(  ), false, accessMode, name.txt )
   scope:addAlge( accessMode, name.txt, algeTypeInfo )
   local nextToken = self:getToken(  )
   while nextToken.txt ~= "}" do
      local valName = self:checkSymbol( nextToken, SymbolMode.MustNot_ )
      if algeTypeInfo:getValInfo( valName.txt ) then
         self:addErrMess( valName.pos, string.format( "multiple symbole -- %s", valName.txt) )
      end
      
      nextToken = self:getToken(  )
      local typeInfoList = {}
      if nextToken.txt == "(" then
         while true do
            local workToken1 = self:getToken(  )
            local workToken2 = self:getToken(  )
            if workToken2.txt ~= ":" then
               self:pushback(  )
               self:pushback(  )
            end
            
            local typeNode = self:analyzeRefType( Ast.AccessMode.Pub, false )
            table.insert( typeInfoList, typeNode:get_expType() )
            nextToken = self:getToken(  )
            if nextToken.txt ~= "," then
               self:checkToken( nextToken, ")" )
               nextToken = self:getToken(  )
               break
            end
            
         end
         
      end
      
      algeScope:addAlgeVal( valName.txt, algeTypeInfo )
      local algeValInfo = Ast.AlgeValInfo.new(valName.txt, typeInfoList)
      algeTypeInfo:addValInfo( algeValInfo )
      if nextToken.txt == "}" then
         break
      end
      
      self:checkToken( nextToken, "," )
      nextToken = self:getToken(  )
   end
   
   self:popScope(  )
   return Nodes.DeclAlgeNode.create( self.nodeManager, firstToken.pos, {algeTypeInfo}, accessMode, algeTypeInfo, algeScope )
end

function TransUnit:analyzeAlias( accessMode, firstToken )

   if self.scope ~= self.moduleScope then
      self:addErrMess( firstToken.pos, "alias must use at top scope." )
   end
   
   local newToken = self:getToken(  )
   self:checkNextToken( "=" )
   local srcToken = self:getToken(  )
   local symbolNode = self:analyzeExpSymbol( firstToken, srcToken, ExpSymbolMode.Symbol, nil, true )
   local newTypeInfo = Ast.builtinTypeNone
   local symbolInfoList = symbolNode:getSymbolInfo(  )
   if #symbolInfoList >= 1 then
      local symbolInfo = symbolInfoList[1]
      if newToken.txt:find( "^_" ) and not srcToken.txt:find( "^_" ) or not newToken.txt:find( "^_" ) and srcToken.txt:find( "^_" ) then
         self:addErrMess( firstToken.pos, string.format( "alias symbol unmatch. %s %s", newToken.txt, newToken.txt) )
      else
       
         do
            local _switchExp = symbolInfo:get_kind()
            if _switchExp == Ast.SymbolKind.Typ or _switchExp == Ast.SymbolKind.Fun then
               local aliasSymbolInfo = self.scope:addAlias( newToken.txt, false, accessMode, self.moduleType, symbolInfo )
               newTypeInfo = aliasSymbolInfo:get_typeInfo()
            else 
               
                  self:addErrMess( firstToken.pos, string.format( "can alias symbol -- %s. (%s)", srcToken.txt, Ast.SymbolKind:_getTxt( symbolInfo:get_kind())
                  ) )
            end
         end
         
      end
      
   else
    
      self:addErrMess( firstToken.pos, string.format( "not found symbold -- %s", srcToken.txt) )
   end
   
   self:checkNextToken( ";" )
   return Nodes.AliasNode.create( self.nodeManager, firstToken.pos, {newTypeInfo}, newToken.txt, symbolNode, newTypeInfo )
end

function TransUnit:analyzeRetTypeList( pubToExtFlag, accessMode, token )

   local retTypeInfoList = {}
   if token.txt == ":" then
      local hasDDDFlag = false
      while true do
         local refTypeNode = self:analyzeRefType( accessMode, true )
         if hasDDDFlag then
            self:addErrMess( refTypeNode:get_pos(), "Type exists after '...'." )
         end
         
         local retType = refTypeNode:get_expType()
         if retType:get_kind() == Ast.TypeInfoKind.DDD then
            hasDDDFlag = true
         end
         
         if pubToExtFlag and not Ast.isPubToExternal( retType:get_accessMode() ) then
            self:addErrMess( refTypeNode:get_pos(), string.format( "this is not public type -- %s", retType:getTxt(  )) )
         end
         
         table.insert( retTypeInfoList, retType )
         token = self:getToken(  )
         if token.txt ~= "," then
            break
         end
         
      end
      
   end
   
   return retTypeInfoList, token
end

function TransUnit:analyzeDeclForm( accessMode, firstToken )

   local name = self:getSymbolToken( SymbolMode.MustNot_ )
   self:checkNextToken( "(" )
   local argList = {}
   local funcBodyScope = self:pushScope( false )
   local nextToken = self:analyzeDeclArgList( accessMode, argList )
   self:checkToken( nextToken, ")" )
   local retTypeList = {}
   nextToken = self:getToken(  )
   retTypeList, nextToken = self:analyzeRetTypeList( Ast.isPubToExternal( accessMode ), accessMode, nextToken )
   self:checkToken( nextToken, ";" )
   self:popScope(  )
   local argTypeInfoList = {}
   for __index, argNode in pairs( argList ) do
      table.insert( argTypeInfoList, argNode:get_expType() )
   end
   
   local formType = Ast.NormalTypeInfo.createFunc( false, false, nil, Ast.TypeInfoKind.FormFunc, self:getCurrentNamespaceTypeInfo(  ), false, false, true, accessMode, name.txt, nil, argTypeInfoList, retTypeList, false )
   self.scope:addForm( formType, accessMode )
   return Nodes.DeclFormNode.create( self.nodeManager, firstToken.pos, {formType}, argList )
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
   
   local abstractFlag = false
   if token.txt == "abstract" then
      abstractFlag = true
      token = self:getToken(  )
   end
   
   if token.txt == "let" then
      return self:analyzeDeclVar( Nodes.DeclVarMode.Let, accessMode, firstToken )
   elseif token.txt == "fn" then
      return self:analyzeDeclFunc( DeclFuncMode.Func, abstractFlag, overrideFlag, accessMode, staticFlag, nil, firstToken, nil )
   elseif token.txt == "class" then
      return self:analyzeDeclClass( abstractFlag, accessMode, firstToken, DeclClassMode.Class )
   elseif token.txt == "interface" then
      return self:analyzeDeclClass( true, accessMode, firstToken, DeclClassMode.Interface )
   elseif token.txt == "module" then
      return self:analyzeDeclClass( false, accessMode, firstToken, DeclClassMode.Module )
   elseif token.txt == "proto" then
      return self:analyzeDeclProto( accessMode, firstToken )
   elseif token.txt == "macro" then
      return self:analyzeDeclMacro( accessMode, firstToken )
   elseif token.txt == "enum" then
      return self:analyzeDeclEnum( accessMode, firstToken )
   elseif token.txt == "alge" then
      return self:analyzeDeclAlge( accessMode, firstToken )
   elseif token.txt == "form" then
      return self:analyzeDeclForm( accessMode, firstToken )
   elseif token.txt == "alias" then
      return self:analyzeAlias( accessMode, firstToken )
   end
   
   return nil
end

function TransUnit:checkPublic( pos, typeInfo )

   local checkedTypeSet = {}
   local function checkPub( workType )
   
      if _lune._Set_has(checkedTypeSet, workType ) then
         return 
      end
      
      checkedTypeSet[workType]= true
      if workType:get_kind() ~= Ast.TypeInfoKind.Array and workType:get_kind() ~= Ast.TypeInfoKind.List and workType:get_kind() ~= Ast.TypeInfoKind.Set and workType:get_kind() ~= Ast.TypeInfoKind.Map and not Ast.isPubToExternal( workType:get_accessMode() ) then
         self:addErrMess( pos, string.format( "not public this type -- %s", workType:getTxt(  )) )
      else
       
         for __index, itemType in pairs( workType:get_itemTypeInfoList() ) do
            checkPub( itemType )
         end
         
      end
      
   end
   
   checkPub( typeInfo )
end

function TransUnit:analyzeDeclMember( classTypeInfo, accessMode, staticFlag, firstToken )

   local nextToken = self:getToken(  )
   local mutMode = Ast.MutMode.IMut
   do
      local _switchExp = nextToken.txt
      if _switchExp == "mut" then
         mutMode = Ast.MutMode.Mut
         nextToken = self:getToken(  )
      elseif _switchExp == "allmut" then
         mutMode = Ast.MutMode.AllMut
         nextToken = self:getToken(  )
      end
   end
   
   local varName = self:checkSymbol( nextToken, SymbolMode.MustNot_ )
   local token = self:getToken(  )
   local refType = self:analyzeRefType( accessMode, false )
   token = self:getToken(  )
   local getterMode = Ast.AccessMode.None
   local getterRetType = refType:get_expType()
   local getterMutable = true
   local setterMode = Ast.AccessMode.None
   if token.txt == "{" then
      local function analyzeAccessorMode(  )
      
         local retType = Ast.headTypeInfo
         local mode = Ast.AccessMode.None
         local workToken = self:getToken(  )
         do
            local _switchExp = workToken.txt
            if _switchExp == "pub" or _switchExp == "pri" or _switchExp == "pro" then
               mode = _lune.unwrap( Ast.txt2AccessMode( workToken.txt ))
               workToken = self:getToken(  )
               if workToken.txt == "&" then
                  getterMutable = false
                  workToken = self:getToken(  )
               end
               
               if workToken.txt == ":" then
                  local typeNode = self:analyzeRefType( mode, false )
                  retType = typeNode:get_expType()
                  workToken = self:getToken(  )
               end
               
            elseif _switchExp == "non" then
               workToken = self:getToken(  )
            else 
               
                  self:addErrMess( workToken.pos, string.format( "access mode is invalid -- %s", workToken.txt) )
            end
         end
         
         return mode, retType, workToken
      end
      
      do
         local workRetType
         
         getterMode, workRetType, nextToken = analyzeAccessorMode(  )
         if workRetType ~= Ast.headTypeInfo then
            if not workRetType:canEvalWith( getterRetType, Ast.CanEvalType.SetOp, classTypeInfo:createAlt2typeMap( false ) ) then
               self:addErrMess( firstToken.pos, string.format( "getter type mismatch -- %s <- %s", workRetType:getTxt(  ), getterRetType:getTxt(  )) )
            end
            
            getterRetType = workRetType
         end
         
      end
      
      if nextToken.txt == "," then
         local dummyRetType
         
         setterMode, dummyRetType, nextToken = analyzeAccessorMode(  )
         if setterMode ~= Ast.AccessMode.None and mutMode == Ast.MutMode.IMut then
            self:addErrMess( varName.pos, string.format( "This member can't have setter, this member is immutable. -- %s", varName.txt) )
         end
         
      end
      
      self:checkToken( nextToken, "}" )
      token = self:getToken(  )
   end
   
   self:checkToken( token, ";" )
   local typeInfo = refType:get_expType()
   if Ast.TypeInfo.isMut( typeInfo ) and typeInfo:get_mutMode() ~= mutMode then
      typeInfo = self:createModifier( typeInfo, mutMode )
   end
   
   if Ast.TypeInfo.isMut( getterRetType ) and getterRetType:get_mutMode() ~= mutMode then
      getterRetType = self:createModifier( getterRetType, mutMode )
   end
   
   if Ast.isPubToExternal( classTypeInfo:get_accessMode() ) then
      if Ast.isPubToExternal( accessMode ) or Ast.isPubToExternal( getterMode ) or Ast.isPubToExternal( setterMode ) then
         self:checkPublic( refType:get_pos(), typeInfo )
      end
      
   end
   
   local symbolInfo = self.scope:addMember( varName.txt, typeInfo, accessMode, staticFlag, mutMode )
   return Nodes.DeclMemberNode.create( self.nodeManager, firstToken.pos, {typeInfo}, varName, refType, symbolInfo, staticFlag, accessMode, getterMutable, getterMode, getterRetType, setterMode )
end

function TransUnit:analyzeDeclMethod( classTypeInfo, declFuncMode, abstractFlag, overrideFlag, accessMode, staticFlag, firstToken, name )

   local node = self:analyzeDeclFunc( declFuncMode, abstractFlag, overrideFlag, accessMode, staticFlag, classTypeInfo, name, name )
   return node
end

function TransUnit:addDefaultConstructor( pos, classTypeInfo, classScope, memberNodeList, methodNameSet, oldFlag )

   if classScope:getTypeInfoChild( "__init" ) then
      self:addErrMess( pos, "already declare __init()." )
   end
   
   local argTypeList = {}
   if classTypeInfo:get_baseTypeInfo() ~= Ast.headTypeInfo then
      local superScope = _lune.unwrap( classTypeInfo:get_baseTypeInfo():get_scope())
      local superTypeInfo = _lune.unwrap( superScope:getTypeInfoChild( "__init" ))
      for __index, argType in pairs( superTypeInfo:get_argTypeInfoList() ) do
         if oldFlag then
            if not argType:get_nilable() then
               self:addErrMess( pos, "not found '__init' decl." )
            end
            
         else
          
            table.insert( argTypeList, argType )
         end
         
      end
      
   end
   
   for __index, memberNode in pairs( memberNodeList ) do
      if not memberNode:get_staticFlag() then
         table.insert( argTypeList, memberNode:get_expType() )
      end
      
   end
   
   local ctorScope = self:pushScope( false )
   local initTypeInfo = Ast.NormalTypeInfo.createFunc( false, false, ctorScope, Ast.TypeInfoKind.Method, classTypeInfo, true, false, false, Ast.AccessMode.Pub, "__init", nil, argTypeList, {} )
   if oldFlag then
      ctorScope:addVar( Ast.AccessMode.Pri, "", Ast.headTypeInfo, Ast.MutMode.IMut, true )
   end
   
   self:popScope(  )
   classScope:addMethod( initTypeInfo, Ast.AccessMode.Pub, false, false )
   methodNameSet["__init"]= true
   for __index, memberNode in pairs( memberNodeList ) do
      if not memberNode:get_staticFlag() then
         memberNode:get_symbolInfo():set_hasValueFlag( true )
      end
      
   end
   
end

function TransUnit:analyzeFuncBlock( analyzingState, firstToken, classTypeInfo, funcName, funcBodyScope, retTypeInfoList )

   if classTypeInfo ~= nil then
      do
         local overrideType = self.scope:get_parent():getTypeInfoField( funcName, false, funcBodyScope )
         if overrideType ~= nil then
            if not overrideType:get_abstractFlag() then
               funcBodyScope:addLocalVar( false, false, "super", overrideType, Ast.MutMode.IMut )
            end
            
         end
      end
      
   end
   
   self:pushAnalyzingState( analyzingState )
   local body = self:analyzeBlock( Nodes.BlockKind.Func, TentativeMode.Ignore, funcBodyScope )
   self:popAnalyzingState(  )
   if #retTypeInfoList ~= 0 then
      local breakKind = body:getBreakKind( Nodes.CheckBreakMode.Return )
      if retTypeInfoList[1] ~= Ast.builtinTypeNeverRet then
         do
            local _switchExp = breakKind
            if _switchExp == Nodes.BreakKind.Return or _switchExp == Nodes.BreakKind.NeverRet then
            else 
               
                  self:addErrMess( firstToken.pos, "This funcion doesn't have return." )
            end
         end
         
      else
       
         if breakKind ~= Nodes.BreakKind.NeverRet then
            self:addErrMess( firstToken.pos, string.format( "This funcion must be never return. -- %s", Nodes.BreakKind:_getTxt( breakKind)
            ) )
         end
         
      end
      
   end
   
   return body
end

function TransUnit:analyzeClassBody( classAccessMode, firstToken, mode, gluePrefix, classTypeInfo, name, moduleName, nextToken )

   local memberName2Node = {}
   local declStmtList = {}
   local fieldList = {}
   local memberList = {}
   local methodNameSet = {}
   local initBlockInfo = Nodes.ClassInitBlockInfo.new()
   local advertiseList = {}
   local trustList = {}
   local node = Nodes.DeclClassNode.create( self.nodeManager, firstToken.pos, {classTypeInfo}, classAccessMode, name, gluePrefix, declStmtList, fieldList, moduleName, memberList, self.scope, initBlockInfo, advertiseList, trustList, {} )
   self.typeInfo2ClassNode[classTypeInfo] = node
   local declCtorNode = nil
   local hasInitBlock = false
   local hasStaticMember = false
   local function processLet( token, staticFlag, accessMode )
   
      if staticFlag then
         hasStaticMember = true
      end
      
      if mode == DeclClassMode.Interface then
         self:addErrMess( token.pos, "interface can not have member" )
      end
      
      if not staticFlag and declCtorNode then
         self:addErrMess( token.pos, "member can't declare after '__init' method." )
      elseif staticFlag and hasInitBlock then
         self:addErrMess( token.pos, "static member can't declare after '__init' block." )
      end
      
      local memberNode = self:analyzeDeclMember( classTypeInfo, accessMode, staticFlag, token )
      table.insert( fieldList, memberNode )
      table.insert( memberList, memberNode )
      memberName2Node[memberNode:get_name().txt] = memberNode
   end
   
   local function processFn( token, staticFlag, accessMode, abstractFlag, overrideFlag )
   
      local nameToken = self:getSymbolToken( SymbolMode.MustNot_ )
      local declFuncMode = DeclFuncMode.Class
      if mode == DeclClassMode.Module then
         if gluePrefix then
            declFuncMode = DeclFuncMode.Glue
         else
          
            declFuncMode = DeclFuncMode.Module
         end
         
      end
      
      local methodNode = self:analyzeDeclMethod( classTypeInfo, declFuncMode, abstractFlag, overrideFlag, accessMode, staticFlag, token, nameToken )
      table.insert( fieldList, methodNode )
      methodNameSet[nameToken.txt]= true
      if nameToken.txt == "__init" then
         declCtorNode = methodNode
      end
      
   end
   
   local function processInitBlock( token )
   
      if mode ~= DeclClassMode.Class then
         self:error( string.format( "%s can not have __init block.", tostring( mode)) )
      end
      
      hasInitBlock = true
      for symbolName, symbolInfo in pairs( self.scope:get_symbol2SymbolInfoMap() ) do
         if symbolInfo:get_staticFlag() then
            symbolInfo:set_hasValueFlag( false )
         end
         
      end
      
      local initBlockScope = self:pushScope( false )
      self:prepareTentativeSymbol( initBlockScope, false )
      local name = "___init"
      local funcTypeInfo = Ast.NormalTypeInfo.createFunc( false, false, initBlockScope, Ast.TypeInfoKind.Func, classTypeInfo, false, false, true, Ast.AccessMode.Pri, name, nil, nil, nil, false )
      local block = self:analyzeFuncBlock( AnalyzingState.InitBlock, token, classTypeInfo, name, initBlockScope, {} )
      local info = Nodes.DeclFuncInfo.new(classTypeInfo, token, {}, true, Ast.AccessMode.Pri, block, {}, false)
      local initBlockNode = Nodes.DeclMethodNode.create( self.nodeManager, firstToken.pos, {funcTypeInfo}, info )
      initBlockInfo:set_func( initBlockNode )
      self:popScope(  )
      self:finishTentativeSymbol( false )
   end
   
   local function processAdvertise(  )
   
      local memberToken = self:getSymbolToken( SymbolMode.MustNot_ )
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
      
      table.insert( advertiseList, Nodes.AdvertiseInfo.new(memberNode, prefix) )
   end
   
   local function processEnum( token, accessMode )
   
      if accessMode ~= Ast.AccessMode.Pri and (classAccessMode == Ast.AccessMode.Pri or classAccessMode == Ast.AccessMode.Local ) then
         self:addErrMess( token.pos, string.format( "unmatch access mode, class('%s') and enum('%s')", Ast.AccessMode:_getTxt( classAccessMode)
         , Ast.AccessMode:_getTxt( accessMode)
         ) )
      end
      
      table.insert( declStmtList, self:analyzeDeclEnum( accessMode, token ) )
   end
   
   local function processLuneControl(  )
   
      nextToken = self:getToken(  )
      do
         local _switchExp = nextToken.txt
         if _switchExp == LuneControl.Pragma.default__init then
            declCtorNode = self:createNoneNode( nextToken.pos )
            self:addDefaultConstructor( nextToken.pos, classTypeInfo, self.scope, memberList, methodNameSet, false )
         elseif _switchExp == LuneControl.Pragma.default__init_old then
            declCtorNode = self:createNoneNode( nextToken.pos )
            self:addDefaultConstructor( nextToken.pos, classTypeInfo, self.scope, memberList, methodNameSet, true )
         else 
            
               self:error( string.format( "unknown option -- %s", nextToken.txt) )
         end
      end
      
      self:checkNextToken( ";" )
   end
   
   local function processClassFields( inMacro )
   
      while true do
         local token = self:getToken( inMacro )
         if token.kind == Parser.TokenKind.Eof or token.txt == "}" then
            break
         end
         
         local accessMode = Ast.txt2AccessMode( token.txt )
         if  nil == accessMode then
            local _accessMode = accessMode
         
            accessMode = Ast.AccessMode.Pri
         else
            
               token = self:getToken(  )
         end
         
         if mode == DeclClassMode.Interface and accessMode ~= Ast.AccessMode.Pub then
            self:addErrMess( token.pos, "interface's fields must be 'pub'." )
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
         
         local abstractFlag = false
         if token.txt == "abstract" then
            abstractFlag = true
            token = self:getToken(  )
         elseif mode == DeclClassMode.Interface then
            abstractFlag = true
         end
         
         if token.txt == "let" then
            processLet( token, staticFlag, accessMode )
         elseif token.txt == "fn" then
            processFn( token, staticFlag, accessMode, abstractFlag, overrideFlag )
         elseif token.txt == "__init" then
            processInitBlock( token )
         elseif token.txt == "advertise" then
            processAdvertise(  )
         elseif token.txt == ";" then
         elseif token.txt == "enum" then
            processEnum( token, accessMode )
         elseif token.txt == "_lune_control" then
            processLuneControl(  )
         else
          
            do
               local symbolInfo = self.scope:getSymbolInfo( token.txt, self.scope, false )
               if symbolInfo ~= nil then
                  if symbolInfo:get_kind() == Ast.SymbolKind.Mac then
                     self:checkNextToken( "(" )
                     local alt2typeMap, argList = self:prepareExpCall( token.pos, symbolInfo:get_typeInfo(), {}, Ast.headTypeInfo )
                     self:evalMacroOp( token, symbolInfo:get_typeInfo(), argList, function (  )
                     
                        processClassFields( true )
                     end
                      )
                     self:checkNextToken( ";" )
                  else
                   
                     self:error( "illegal field" )
                  end
                  
               else
                  self:error( "illegal field" )
               end
            end
            
         end
         
      end
      
   end
   
   processClassFields( false )
   if mode ~= DeclClassMode.Module then
      if declCtorNode ~= nil then
         for memberName, memberNode in pairs( memberName2Node ) do
            if not memberNode:get_staticFlag() then
               local symbolInfo = _lune.unwrap( self.scope:getSymbolInfoChild( memberName ))
               local typeInfo = symbolInfo:get_typeInfo()
               if not symbolInfo:get_hasValueFlag() and not typeInfo:get_nilable() then
                  self:addErrMess( declCtorNode:get_pos(), string.format( "Set member -- %s.%s", name.txt, memberName) )
               end
               
            end
            
         end
         
      end
      
      if hasStaticMember and not hasInitBlock then
         self:addErrMess( node:get_pos(), string.format( "This class (%s) need __init block for initialize static members.", name.txt) )
      end
      
      for memberName, memberNode in pairs( memberName2Node ) do
         if memberNode:get_staticFlag() then
            local symbolInfo = _lune.unwrap( self.scope:getSymbolInfoChild( memberName ))
            local typeInfo = symbolInfo:get_typeInfo()
            if not symbolInfo:get_hasValueFlag() and not typeInfo:get_nilable() then
               self:addErrMess( memberNode:get_pos(), string.format( "Set member -- %s", memberName) )
            end
            
         end
         
      end
      
   end
   
   return node, nextToken, methodNameSet
end

function TransUnit:analyzeDeclClass( classAbstructFlag, classAccessMode, firstToken, mode )

   if mode ~= DeclClassMode.Module then
      do
         local _switchExp = self:getCurrentNamespaceTypeInfo(  ):get_kind()
         if _switchExp == Ast.TypeInfoKind.IF or _switchExp == Ast.TypeInfoKind.Class or _switchExp == Ast.TypeInfoKind.Module then
         elseif _switchExp == Ast.TypeInfoKind.Func or _switchExp == Ast.TypeInfoKind.Method then
            do
               local _switchExp = classAccessMode
               if _switchExp == Ast.AccessMode.Pub or _switchExp == Ast.AccessMode.Global then
                  self:addErrMess( firstToken.pos, "Class can't declare on here." )
               end
            end
            
         else 
            
               self:addErrMess( firstToken.pos, "Class can't declare on here." )
         end
      end
      
   end
   
   local name = self:getSymbolToken( SymbolMode.MustNot_ )
   local altTypeList = {}
   do
      local nextToken = self:getToken(  )
      if nextToken.txt == "<" then
         nextToken, altTypeList = self:analyzeDeclAlternateType( true, nextToken, classAccessMode )
      end
      
      self:pushbackToken( nextToken )
   end
   
   if classAccessMode == Ast.AccessMode.Local then
      classAccessMode = Ast.AccessMode.Pri
   end
   
   local moduleName = nil
   local gluePrefix = nil
   if mode == DeclClassMode.Module then
      self:checkNextToken( "require" )
      moduleName = self:getToken(  )
      local nextToken = self:getToken(  )
      if nextToken.txt == "glue" then
         gluePrefix = self:getToken(  ):getExcludedDelimitTxt(  )
      else
       
         self:pushback(  )
      end
      
   end
   
   local existSymbolInfo = self.scope:getSymbolTypeInfo( name.txt, self.scope, self.scope )
   local nextToken, classTypeInfo = self:analyzePushClass( mode ~= DeclClassMode.Interface, classAbstructFlag, firstToken, name, classAccessMode, altTypeList )
   if self.protoClassMap[classTypeInfo] then
      self.protoClassMap[classTypeInfo] = nil
   else
    
      if existSymbolInfo then
         self:addErrMess( name.pos, string.format( "already declare symbol -- %s", name.txt) )
      end
      
   end
   
   local classScope = self.scope
   self:checkToken( nextToken, "{" )
   local mapType = Ast.NormalTypeInfo.createMap( Ast.AccessMode.Pub, classTypeInfo, Ast.builtinTypeString, self:createModifier( Ast.builtinTypeStem, Ast.MutMode.IMut ), Ast.MutMode.IMut )
   if classTypeInfo:isInheritFrom( Ast.builtinTypeMapping, nil ) then
      self.helperInfo.hasMappingClassDef = true
      if classTypeInfo:get_baseTypeInfo() ~= Ast.headTypeInfo and not classTypeInfo:get_baseTypeInfo():isInheritFrom( Ast.builtinTypeMapping, nil ) then
         self:addErrMess( firstToken.pos, string.format( "must extend Mapping at %s", classTypeInfo:get_baseTypeInfo():getTxt(  )) )
      end
      
      local toMapFuncTypeInfo = Ast.NormalTypeInfo.createFunc( false, false, nil, Ast.TypeInfoKind.Method, classTypeInfo, true, false, false, Ast.AccessMode.Pub, "_toMap", nil, {}, {mapType}, false )
      classScope:addMethod( toMapFuncTypeInfo, Ast.AccessMode.Pub, false, false )
   end
   
   local node, workNextToken, methodNameSet = self:analyzeClassBody( classAccessMode, firstToken, mode, gluePrefix, classTypeInfo, name, moduleName, nextToken )
   nextToken = workNextToken
   local parentInfo = classTypeInfo
   for __index, memberNode in pairs( node:get_memberList() ) do
      local memberType = memberNode:get_expType()
      local memberName = memberNode:get_name()
      local getterName = "get_" .. memberName.txt
      local accessMode = memberNode:get_getterMode()
      if accessMode ~= Ast.AccessMode.None and not classScope:getTypeInfoChild( getterName ) then
         local mutable = memberNode:get_getterMutable()
         local getterMemberType = memberNode:get_getterRetType()
         if Ast.TypeInfo.isMut( getterMemberType ) and not mutable then
            getterMemberType = self:createModifier( getterMemberType, Ast.MutMode.IMut )
         end
         
         local retTypeInfo = Ast.NormalTypeInfo.createFunc( false, false, self:pushScope( false ), Ast.TypeInfoKind.Method, parentInfo, true, false, memberNode:get_staticFlag(), accessMode, getterName, nil, {}, {getterMemberType} )
         self:popScope(  )
         classScope:addMethod( retTypeInfo, accessMode, memberNode:get_staticFlag(), false )
         methodNameSet[getterName]= true
      end
      
      local setterName = "set_" .. memberName.txt
      accessMode = memberNode:get_setterMode()
      if memberNode:get_setterMode() ~= Ast.AccessMode.None and not classScope:getTypeInfoChild( setterName ) then
         classScope:addMethod( Ast.NormalTypeInfo.createFunc( false, false, self:pushScope( false ), Ast.TypeInfoKind.Method, parentInfo, true, false, memberNode:get_staticFlag(), accessMode, setterName, nil, {memberType}, nil, true ), accessMode, memberNode:get_staticFlag(), true )
         self:popScope(  )
         methodNameSet[setterName]= true
      end
      
   end
   
   local ctorAccessMode = Ast.AccessMode.Pub
   do
      local ctorTypeInfo = classScope:getTypeInfoChild( "__init" )
      if ctorTypeInfo ~= nil then
         ctorAccessMode = ctorTypeInfo:get_accessMode()
      else
         self:addDefaultConstructor( firstToken.pos, classTypeInfo, classScope, node:get_memberList(), methodNameSet, false )
      end
   end
   
   for __index, advertiseInfo in pairs( node:get_advertiseList() ) do
      local memberType = advertiseInfo:get_member():get_expType()
      do
         local _switchExp = memberType:get_kind()
         if _switchExp == Ast.TypeInfoKind.Class or _switchExp == Ast.TypeInfoKind.IF then
            for __index, child in pairs( memberType:get_children() ) do
               if child:get_kind() == Ast.TypeInfoKind.Method and child:get_accessMode() ~= Ast.AccessMode.Pri and not child:get_staticFlag() then
                  local childName = advertiseInfo:get_prefix() .. child:getTxt(  )
                  if not _lune._Set_has(methodNameSet, childName ) then
                     local impMtdType = Ast.NormalTypeInfo.createAdvertiseMethodFrom( classTypeInfo, child )
                     classScope:addMethod( impMtdType, child:get_accessMode(), child:get_staticFlag(), false )
                  end
                  
               end
               
            end
            
         else 
            
               self:error( string.format( "advertise member type is illegal -- %s", tostring( advertiseInfo:get_member():get_name())) )
         end
      end
      
   end
   
   if classTypeInfo:isInheritFrom( Ast.builtinTypeMapping, nil ) then
      local checkedTypeMap = {}
      for __index, memberNode in pairs( node:get_memberList() ) do
         local memberType = memberNode:get_expType()
         if not Ast.NormalTypeInfo.isAvailableMapping( memberType, checkedTypeMap ) then
            self:addErrMess( memberNode:get_pos(), string.format( "member type is not Mapping -- %s", memberType:getTxt(  )) )
         end
         
      end
      
      local fromMapFuncTypeInfo = Ast.NormalTypeInfo.createFunc( false, false, nil, Ast.TypeInfoKind.Func, classTypeInfo, true, false, true, Ast.AccessMode.Pub, "_fromMap", nil, {mapType:get_nilableTypeInfo()}, {classTypeInfo:get_nilableTypeInfo(), Ast.builtinTypeString:get_nilableTypeInfo()}, true )
      classScope:addMethod( fromMapFuncTypeInfo, ctorAccessMode, true, false )
      local fromStemFuncTypeInfo = Ast.NormalTypeInfo.createFunc( false, false, nil, Ast.TypeInfoKind.Func, classTypeInfo, true, false, true, Ast.AccessMode.Pub, "_fromStem", nil, {Ast.builtinTypeStem_}, {classTypeInfo:get_nilableTypeInfo(), Ast.builtinTypeString:get_nilableTypeInfo()}, true )
      classScope:addMethod( fromStemFuncTypeInfo, ctorAccessMode, true, false )
   end
   
   self:popClass(  )
   return node
end

function TransUnit:addMethod( classTypeInfo, methodNode, name )

   local classNodeInfo = _lune.unwrap( self.typeInfo2ClassNode[classTypeInfo])
   classNodeInfo:get_outerMethodSet()[name]= true
   table.insert( classNodeInfo:get_fieldList(), methodNode )
end

function TransUnit:analyzeDeclFunc( declFuncMode, abstractFlag, overrideFlag, accessMode, staticFlag, classTypeInfo, firstToken, name )

   local token = self:getToken(  )
   do
      local _exp = name
      if _exp ~= nil then
         name = self:checkSymbol( _exp, SymbolMode.MustNot_ )
      else
         if token.txt ~= "(" then
            name = self:checkSymbol( token, SymbolMode.MustNot_ )
            token = self:getToken(  )
         end
         
      end
   end
   
   local needPopFlag = false
   if token.txt == "." then
      needPopFlag = true
      local className = (_lune.unwrap( name) ).txt
      classTypeInfo = self.scope:getTypeInfoChild( className )
      if classTypeInfo ~= nil then
         self:pushClass( classTypeInfo:get_kind() == Ast.TypeInfoKind.Class, classTypeInfo:get_abstractFlag(), nil, nil, {}, false, className, classTypeInfo:get_accessMode() )
      else
         self:error( string.format( "not found class -- %s", className) )
      end
      
      name = self:getSymbolToken( SymbolMode.MustNot_ )
      token = self:getToken(  )
      if accessMode == Ast.AccessMode.Local then
         accessMode = Ast.AccessMode.Pri
      end
      
   end
   
   local isCtorFlag = false
   local kind = Nodes.NodeKind.get_DeclConstr()
   local typeKind = Ast.TypeInfoKind.Func
   if classTypeInfo then
      if not staticFlag then
         typeKind = Ast.TypeInfoKind.Method
      end
      
      do
         local _switchExp = (_lune.unwrap( name) ).txt
         if _switchExp == "__init" then
            isCtorFlag = true
            kind = Nodes.NodeKind.get_DeclConstr()
            for symbolName, symbolInfo in pairs( self.scope:get_symbol2SymbolInfoMap() ) do
               if not symbolInfo:get_staticFlag() then
                  symbolInfo:set_hasValueFlag( false )
               end
               
            end
            
         elseif _switchExp == "__free" then
            kind = Nodes.NodeKind.get_DeclDestr()
            if not self.targetLuaVer:get_canUseMetaGc() then
               self:addErrMess( firstToken.pos, "this lua version is not support __free." )
            end
            
         else 
            
               kind = Nodes.NodeKind.get_DeclMethod()
         end
      end
      
   else
    
      kind = Nodes.NodeKind.get_DeclFunc()
      if not staticFlag then
         staticFlag = true
      end
      
   end
   
   local orgStaticFlag = staticFlag
   if declFuncMode == DeclFuncMode.Module then
      staticFlag = true
   end
   
   local funcName = ""
   if name ~= nil then
      funcName = name.txt
      if kind == Nodes.NodeKind.get_DeclFunc() then
         do
            local _switchExp = accessMode
            if _switchExp == Ast.AccessMode.Pub or _switchExp == Ast.AccessMode.Global then
               if self.scope ~= self.moduleScope then
                  self:addErrMess( firstToken.pos, "'global' or 'pub' function must exist top scope." )
               end
               
            end
         end
         
      end
      
   end
   
   local funcBodyScope = self:pushScope( false )
   local altTypeList = {}
   if token.txt == "<" then
      token, altTypeList = self:analyzeDeclAlternateType( false, token, accessMode )
      for __index, altType in pairs( altTypeList ) do
         funcBodyScope:addAlternate( accessMode, altType:get_rawTxt(), altType )
      end
      
   end
   
   self:checkToken( token, "(" )
   local argList = {}
   token = self:analyzeDeclArgList( accessMode, argList )
   self:checkToken( token, ")" )
   token = self:getToken(  )
   local mutable = false
   if token.txt == "mut" then
      token = self:getToken(  )
      mutable = true
   end
   
   local pubToExtFlag = Ast.isPubToExternal( accessMode )
   local argTypeList = {}
   for __index, argNode in pairs( argList ) do
      table.insert( argTypeList, argNode:get_expType() )
   end
   
   local alt2typeMap = Ast.CanEvalCtrlTypeInfo.createDefaultAlt2typeMap( false )
   if classTypeInfo ~= nil then
      alt2typeMap = classTypeInfo:createAlt2typeMap( false )
      if kind == Nodes.NodeKind.get_DeclMethod() or kind == Nodes.NodeKind.get_DeclConstr() or kind == Nodes.NodeKind.get_DeclDestr() then
         local workClass = classTypeInfo
         if kind == Nodes.NodeKind.get_DeclConstr() or kind == Nodes.NodeKind.get_DeclDestr() then
            mutable = true
         end
         
         if not Ast.isPubToExternal( workClass:get_accessMode() ) then
            pubToExtFlag = false
         end
         
         if Ast.TypeInfo.isMut( workClass ) and not mutable then
            workClass = self:createModifier( workClass, Ast.MutMode.IMut )
         end
         
         if not staticFlag then
            self.scope:add( Ast.SymbolKind.Arg, false, true, "self", workClass, Ast.AccessMode.Pri, false, mutable and Ast.MutMode.Mut or Ast.MutMode.IMut, true )
         end
         
         if not workClass:get_abstractFlag() and abstractFlag then
            self:addErrMess( firstToken.pos, "no abstract class does not have abstract method" )
         end
         
      end
      
   end
   
   local retTypeInfoList = {}
   retTypeInfoList, token = self:analyzeRetTypeList( pubToExtFlag, accessMode, token )
   local namespaceInfo = self:getCurrentNamespaceTypeInfo(  )
   local typeInfo = Ast.NormalTypeInfo.createFunc( abstractFlag, false, funcBodyScope, typeKind, namespaceInfo, false, false, staticFlag, accessMode, funcName, altTypeList, argTypeList, retTypeInfoList, mutable )
   if name ~= nil then
      local parentScope = funcBodyScope:get_parent(  )
      if accessMode == Ast.AccessMode.Global then
         parentScope = self.globalScope
      end
      
      do
         local prottype = parentScope:getTypeInfoChild( typeInfo:get_rawTxt() )
         if prottype ~= nil then
            do
               local matchFlag, err = Ast.TypeInfo.checkMatchType( prottype:get_argTypeInfoList(), argTypeList, false, nil, alt2typeMap )
               if matchFlag ~= Ast.MatchType.Match then
                  self:addErrMess( name.pos, "mismatch functype param: " .. err )
               end
               
            end
            
            do
               local matchFlag, err = Ast.TypeInfo.checkMatchType( prottype:get_retTypeInfoList(), retTypeInfoList, false, nil, alt2typeMap )
               if matchFlag ~= Ast.MatchType.Match then
                  self:addErrMess( name.pos, "mismatch functype ret: " .. err )
               end
               
            end
            
            if not typeInfo:canEvalWith( prottype, Ast.CanEvalType.SetOp, alt2typeMap ) then
               self:addErrMess( name.pos, string.format( "mismatch functype -- %s / %s", typeInfo:get_display_stirng(), prottype:get_display_stirng()) )
            end
            
            if self.protoFuncMap[prottype] then
               self.protoFuncMap[prottype] = nil
            else
             
               if not prottype:get_autoFlag() then
                  self:addErrMess( token.pos, string.format( "multiple define -- %s", name.txt) )
               end
               
            end
            
         end
      end
      
      if kind == Nodes.NodeKind.get_DeclFunc() then
         parentScope:addFunc( typeInfo, accessMode, staticFlag, mutable )
      else
       
         parentScope:addMethod( typeInfo, accessMode, staticFlag, mutable )
      end
      
   end
   
   if overrideFlag then
      if not name then
         self:addErrMess( firstToken.pos, "can't override anonymous func" )
      end
      
      
      do
         local overrideType = self.scope:get_parent():getTypeInfoField( funcName, false, funcBodyScope )
         if overrideType ~= nil then
            if overrideType:get_accessMode(  ) ~= accessMode then
               self:addErrMess( firstToken.pos, string.format( "mismatch override accessMode -- %s,%s,%s", funcName, Ast.AccessMode:_getTxt( overrideType:get_accessMode(  ))
               , Ast.AccessMode:_getTxt( accessMode)
               ) )
            end
            
            if overrideType:get_staticFlag(  ) ~= staticFlag then
               self:addErrMess( firstToken.pos, "mismatch override staticFlag -- " .. funcName )
            end
            
            if overrideType:get_kind(  ) ~= Ast.TypeInfoKind.Method then
               self:addErrMess( firstToken.pos, string.format( "mismatch override kind -- %s, %d", funcName, overrideType:get_kind(  )) )
            end
            
            if overrideType:get_mutMode() ~= typeInfo:get_mutMode() then
               self:addErrMess( firstToken.pos, string.format( "mismatch mutable -- %s", funcName) )
            end
            
            if #overrideType:get_itemTypeInfoList() ~= #altTypeList then
               self:addErrMess( firstToken.pos, string.format( "mismatch altTypeList -- %d, %d", #overrideType:get_itemTypeInfoList(), #altTypeList) )
            else
             
               for index, alterType in pairs( overrideType:get_itemTypeInfoList() ) do
                  alt2typeMap[alterType] = altTypeList[index]
               end
               
            end
            
            if not overrideType:canEvalWith( typeInfo, Ast.CanEvalType.SetOp, alt2typeMap ) then
               self:addErrMess( firstToken.pos, string.format( "mismatch method type -- %s", funcName) )
            end
            
         else
            self:addErrMess( firstToken.pos, "not found override -- " .. funcName )
         end
      end
      
   else
    
      if name ~= nil then
         if name.txt ~= "__init" then
            if self.scope:get_parent():getTypeInfoField( name.txt, false, funcBodyScope ) then
               self:addErrMess( firstToken.pos, "mismatch override --" .. funcName )
            else
             
               do
                  local ifFunc = self.scope:get_parent():getSymbolInfoIfField( name.txt, funcBodyScope )
                  if ifFunc ~= nil then
                     if not ifFunc:get_typeInfo():canEvalWith( typeInfo, Ast.CanEvalType.SetOp, alt2typeMap ) then
                        self:addErrMess( firstToken.pos, string.format( "mismatch method type -- %s", funcName) )
                     end
                     
                  end
               end
               
            end
            
         end
         
      end
      
   end
   
   local node = self:createNoneNode( firstToken.pos )
   local needNode = false
   local body = nil
   if token.txt == ";" then
      if declFuncMode == DeclFuncMode.Module or declFuncMode == DeclFuncMode.Glue then
         needNode = true
      else
       
         if not abstractFlag then
            self.protoFuncMap[typeInfo] = firstToken.pos
         end
         
      end
      
      if _lune.nilacc( classTypeInfo, 'get_kind', 'callmtd' ) == Ast.TypeInfoKind.IF then
         needNode = true
      end
      
   else
    
      needNode = true
      if abstractFlag then
         self:addErrMess( token.pos, "abstract method can't have body." )
      end
      
      self:pushback(  )
      local analyzingState
      
      if isCtorFlag then
         analyzingState = AnalyzingState.Constructor
      elseif staticFlag and classTypeInfo then
         analyzingState = AnalyzingState.ClassMethod
      else
       
         analyzingState = AnalyzingState.Func
      end
      
      funcBodyScope:addLocalVar( false, false, "__func__", Ast.builtinTypeString, Ast.MutMode.IMut )
      local workBody = self:analyzeFuncBlock( analyzingState, firstToken, classTypeInfo, funcName, funcBodyScope, retTypeInfoList )
      body = workBody
      if isCtorFlag then
         if classTypeInfo ~= nil then
            if classTypeInfo:get_baseTypeInfo() ~= Ast.headTypeInfo then
               if #workBody:get_stmtList() == 0 or workBody:get_stmtList()[1]:get_kind() ~= Nodes.nodeKind['ExpCallSuper'] then
                  self:addErrMess( workBody:get_pos(), "__init must call super() with first." )
               end
               
            end
            
         end
         
      end
      
   end
   
   if needNode then
      local info = Nodes.DeclFuncInfo.new(classTypeInfo, name, argList, orgStaticFlag, accessMode, body, retTypeInfoList, _lune._Set_has(self.has__func__Symbol, typeInfo ))
      do
         local _switchExp = (kind )
         if _switchExp == Nodes.NodeKind.get_DeclConstr() then
            node = Nodes.DeclConstrNode.create( self.nodeManager, firstToken.pos, {typeInfo}, info )
         elseif _switchExp == Nodes.NodeKind.get_DeclDestr() then
            node = Nodes.DeclDestrNode.create( self.nodeManager, firstToken.pos, {typeInfo}, info )
         elseif _switchExp == Nodes.NodeKind.get_DeclMethod() then
            node = Nodes.DeclMethodNode.create( self.nodeManager, firstToken.pos, {typeInfo}, info )
         elseif _switchExp == Nodes.NodeKind.get_DeclFunc() then
            node = Nodes.DeclFuncNode.create( self.nodeManager, firstToken.pos, {typeInfo}, info )
         else 
            
               self:error( string.format( "illegal kind -- %d", kind) )
         end
      end
      
   end
   
   self.has__func__Symbol[typeInfo]= nil
   self:popScope(  )
   if needPopFlag then
      self:addMethod( _lune.unwrap( classTypeInfo), node, funcName )
      self:popClass(  )
   end
   
   return node
end

function TransUnit:createExpListNode( orgExpList, newExpList )

   local newExpTypeList = {}
   for listIndex, expNode in pairs( newExpList ) do
      table.insert( newExpTypeList, expNode:get_expType() )
   end
   
   if #newExpList[#newExpList]:get_expTypeList() > 1 then
      self:addErrMess( orgExpList:get_pos(), string.format( "illegal exp -- %d", #newExpList[#newExpList]:get_expTypeList()) )
   end
   
   do
      local mRetIndex = _lune.nilacc( orgExpList:get_mRetExp(), 'get_index', 'callmtd' )
      if mRetIndex ~= nil then
         if mRetIndex > #newExpList then
            self:addErrMess( orgExpList:get_pos(), string.format( "over index -- %d", mRetIndex) )
         end
         
      end
   end
   
   return Nodes.ExpListNode.create( self.nodeManager, orgExpList:get_pos(), newExpTypeList, newExpList, orgExpList:get_mRetExp(), orgExpList:get_followOn() )
end

local LetVarInfo = {}
function LetVarInfo.setmeta( obj )
  setmetatable( obj, { __index = LetVarInfo  } )
end
function LetVarInfo.new( mutable, varName, varType )
   local obj = {}
   LetVarInfo.setmeta( obj )
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

function TransUnit:analyzeLetAndInitExp( firstPos, initMutable, accessMode, unwrapFlag )

   local typeInfoList = {}
   local letVarList = {}
   local nextToken = Parser.getEofToken(  )
   repeat 
      local mutable = initMutable
      nextToken = self:getToken(  )
      if nextToken.txt == "mut" then
         mutable = Ast.MutMode.Mut
         nextToken = self:getToken(  )
      end
      
      local varName = self:checkSymbol( nextToken, SymbolMode.MustNot_ )
      nextToken = self:getToken(  )
      local typeInfo = Ast.builtinTypeEmpty
      if nextToken.txt == ":" then
         local refType = self:analyzeRefType( accessMode, false )
         table.insert( letVarList, LetVarInfo.new(mutable, varName, refType) )
         typeInfo = refType:get_expType()
         nextToken = self:getToken(  )
      else
       
         table.insert( letVarList, LetVarInfo.new(Ast.isMutable( mutable ) and mutable or Ast.MutMode.IMutRe, varName, nil) )
      end
      
      if not typeInfo:equals( Ast.builtinTypeEmpty ) and Ast.TypeInfo.isMut( typeInfo ) and not Ast.isMutable( mutable ) then
         typeInfo = self:createModifier( typeInfo, Ast.MutMode.IMutRe )
      end
      
      table.insert( typeInfoList, typeInfo )
   until nextToken.txt ~= ","
   local expList = nil
   if nextToken.txt == "=" then
      local expectTypeList = {}
      for __index, varInfo in pairs( letVarList ) do
         table.insert( expectTypeList, _lune.unwrapDefault( _lune.nilacc( varInfo.varType, 'get_expType', 'callmtd' ), Ast.builtinTypeNone) )
      end
      
      expList = self:analyzeExpList( false, false, nil, expectTypeList )
      if not expList then
         self:error( "expList is nil" )
      end
      
   else
    
      self:pushback(  )
   end
   
   local orgExpTypeList = {}
   if expList ~= nil then
      local updateExpList = false
      local newExpList = {}
      for index, exp in pairs( expList:get_expList() ) do
         table.insert( newExpList, exp )
         if not exp:canBeRight(  ) then
            self:addErrMess( exp:get_pos(), string.format( "this node(%d) can not be r-value. -- %s", index, Nodes.getNodeKindName( exp:get_kind() )) )
         end
         
      end
      
      local expTypeList = {}
      for index, expType in pairs( expList:get_expTypeList() ) do
         local processedFlag = false
         if index == #expList:get_expTypeList() and expType:get_kind() == Ast.TypeInfoKind.DDD then
            local dddItemType = Ast.builtinTypeStem_
            if #expType:get_itemTypeInfoList() > 0 then
               dddItemType = expType:get_itemTypeInfoList()[1]:get_nilableTypeInfo()
            end
            
            for subIndex = index, #letVarList do
               local argType = typeInfoList[subIndex]
               local checkType = dddItemType
               if unwrapFlag then
                  checkType = dddItemType:get_nonnilableType()
               end
               
               if not argType:equals( Ast.builtinTypeEmpty ) and not argType:canEvalWith( checkType, Ast.CanEvalType.SetOp, {} ) then
                  self:addErrMess( firstPos, string.format( "unmatch value type (index = %d) %s) <- %s", subIndex, argType:getTxt( true ), dddItemType:getTxt(  )) )
               end
               
               table.insert( expTypeList, checkType )
               table.insert( orgExpTypeList, dddItemType )
            end
            
         else
          
            local expTypeInfo = expType
            if expType:get_kind() == Ast.TypeInfoKind.DDD then
               local itemList = expType:get_itemTypeInfoList()
               if #itemList > 0 then
                  expTypeInfo = itemList[1]
               else
                
                  expTypeInfo = Ast.builtinTypeStem_
               end
               
            end
            
            table.insert( orgExpTypeList, expTypeInfo )
            if expTypeInfo == Ast.builtinTypeNil and index <= #typeInfoList then
               orgExpTypeList[index] = typeInfoList[index]:get_nilableTypeInfo()
            end
            
            if unwrapFlag and expTypeInfo:get_nilable() then
               expTypeInfo = expTypeInfo:get_nonnilableType()
            end
            
            if index <= #typeInfoList then
               local varType = typeInfoList[index]
               local alt2typeMap = Ast.CanEvalCtrlTypeInfo.createDefaultAlt2typeMap( false )
               if varType:get_kind() == Ast.TypeInfoKind.Box then
                  alt2typeMap = varType:createAlt2typeMap( true )
               end
               
               Ast.CanEvalCtrlTypeInfo.setupNeedAutoBoxing( alt2typeMap )
               if not varType:equals( Ast.builtinTypeEmpty ) and not varType:canEvalWith( expTypeInfo, Ast.CanEvalType.SetOp, alt2typeMap ) and not (unwrapFlag and expTypeInfo:equals( Ast.builtinTypeNil ) ) then
                  self:addErrMess( firstPos, string.format( "unmatch value type (index:%d) %s <- %s", index, varType:getTxt( true ), expTypeInfo:getTxt( true )) )
               end
               
               if varType == Ast.builtinTypeBox then
                  typeInfoList[index] = Ast.NormalTypeInfo.createBox( accessMode, expTypeInfo )
               end
               
               if Ast.CanEvalCtrlTypeInfo.canAutoBoxing( varType, expTypeInfo ) then
                  updateExpList = true
                  local exp = newExpList[index]
                  newExpList[index] = Nodes.BoxingNode.create( self.nodeManager, exp:get_pos(), {varType}, exp )
                  if not Ast.CanEvalCtrlTypeInfo.finishNeedAutoBoxing( alt2typeMap, 1 ) then
                     self:addErrMess( exp:get_pos(), string.format( "auto boxing error %s <- %s", varType:getTxt(  ), expTypeInfo:getTxt(  )) )
                  end
                  
               else
                
                  if not Ast.CanEvalCtrlTypeInfo.finishNeedAutoBoxing( alt2typeMap, 0 ) then
                     self:addErrMess( newExpList[index]:get_pos(), string.format( "illegal auto boxing error %s <- %s", varType:getTxt(  ), expTypeInfo:getTxt(  )) )
                  end
                  
               end
               
            end
            
            table.insert( expTypeList, expTypeInfo )
         end
         
      end
      
      if updateExpList then
         expList = self:createExpListNode( expList, newExpList )
      end
      
      do
         local alt2typeMap = Ast.CanEvalCtrlTypeInfo.createDefaultAlt2typeMap( false )
         do
            local workList = self:checkImplicitCast( alt2typeMap, typeInfoList, expList, function ( dstType, expNode )
            
               return nil
            end
             )
            if workList ~= nil then
               expList = workList
            end
         end
         
      end
      
      for index, varType in pairs( typeInfoList ) do
         if index > #expTypeList then
            if not varType:get_nilable() then
               self:addErrMess( firstPos, string.format( "unmatch value type (index:%d) %s <- nil", index, varType:getTxt( true )) )
            end
            
         end
         
      end
      
      for index, typeInfo in pairs( expTypeList ) do
         if #typeInfoList < index or typeInfoList[index]:equals( Ast.builtinTypeEmpty ) then
            if Ast.TypeInfo.isMut( typeInfo ) and index <= #letVarList and not Ast.isMutable( letVarList[index].mutable ) then
               typeInfoList[index] = self:createModifier( typeInfo, Ast.MutMode.IMutRe )
            else
             
               typeInfoList[index] = typeInfo
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
      if mode ~= Nodes.DeclVarMode.Let then
         Util.log( "need '!'" )
      end
      
   end
   
   if accessMode == Ast.AccessMode.Pub then
      if self.scope ~= self.moduleScope then
         self:addErrMess( firstToken.pos, "'pub' variable must exist top scope." )
      end
      
   end
   
   local typeInfoList, letVarList, orgExpTypeList, expList = self:analyzeLetAndInitExp( firstToken.pos, mode == Nodes.DeclVarMode.Sync and Ast.MutMode.Mut or Ast.MutMode.IMut, accessMode, unwrapFlag )
   if mode ~= Nodes.DeclVarMode.Sync and self.macroScope then
      for index, letVarInfo in pairs( letVarList ) do
         local typeInfo = typeInfoList[index]
         self.symbol2ValueMapForMacro[letVarInfo.varName.txt] = Nodes.MacroValInfo.new(nil, typeInfo, nil)
      end
      
   end
   
   local syncScope = self.scope
   if mode == Nodes.DeclVarMode.Sync then
      syncScope = self:pushScope( false )
   end
   
   local symbolInfoList = {}
   local varList = {}
   local syncSymbolList = {}
   for index, letVarInfo in pairs( letVarList ) do
      local varName = letVarInfo.varName
      local typeInfo = typeInfoList[index]
      local varInfo = Nodes.VarInfo.new(varName, letVarInfo.varType, typeInfo)
      table.insert( varList, varInfo )
      if Ast.isPubToExternal( accessMode ) then
         self:checkPublic( varName.pos, typeInfo )
      end
      
      if not letVarInfo.varType and typeInfo:equals( Ast.builtinTypeNil ) then
         self:addErrMess( varName.pos, string.format( 'need type -- %s', varName.txt) )
      end
      
      if mode == Nodes.DeclVarMode.Sync then
         if self.scope:getTypeInfo( varName.txt, self.scope, true ) then
            table.insert( syncSymbolList, varInfo )
         end
         
      end
      
      if mode == Nodes.DeclVarMode.Let or mode == Nodes.DeclVarMode.Sync then
         if mode == Nodes.DeclVarMode.Let then
            if self.scope:getTypeInfo( varName.txt, self.scope, true ) then
               self:addErrMess( varName.pos, string.format( "shadowing variable -- %s", varName.txt) )
            end
            
         end
         
         local orgExpType = Ast.builtinTypeStem_
         if not unwrapFlag then
            orgExpType = Ast.builtinTypeEmpty
         end
         
         if index <= #orgExpTypeList then
            orgExpType = orgExpTypeList[index]
         end
         
         local hasValue = false
         if not unwrapFlag and orgExpType ~= Ast.builtinTypeEmpty or unwrapFlag and not orgExpType:get_nilable() then
            hasValue = true
         end
         
         self.scope:addVar( accessMode, varName.txt, typeInfo, letVarInfo.mutable, hasValue )
      end
      
      table.insert( symbolInfoList, _lune.unwrap( self.scope:getSymbolInfo( varName.txt, self.scope, true )) )
   end
   
   local unwrapBlock = nil
   local thenBlock = nil
   if unwrapFlag then
      local scope = self:pushScope( false )
      for index, letVarInfo in pairs( letVarList ) do
         self:addLocalVar( letVarInfo.varName.pos, false, true, "_" .. letVarInfo.varName.txt, orgExpTypeList[index], Ast.MutMode.IMut )
      end
      
      unwrapBlock = self:analyzeBlock( Nodes.BlockKind.LetUnwrap, TentativeMode.Start, scope )
      self:popScope(  )
      if mode == Nodes.DeclVarMode.Let or mode == Nodes.DeclVarMode.Sync then
         if unwrapBlock ~= nil then
            local breakKind = unwrapBlock:getBreakKind( Nodes.CheckBreakMode.Normal )
            for __index, letVarInfo in pairs( letVarList ) do
               local symbolInfo = _lune.unwrap( self.scope:getSymbolInfoChild( letVarInfo.varName.txt ))
               if breakKind ~= Nodes.BreakKind.None then
                  self.tentativeSymbol:checkAndExclude( symbolInfo )
                  symbolInfo:set_hasValueFlag( true )
               else
                
                  if not self.tentativeSymbol:checkAndExclude( symbolInfo ) then
                     if not symbolInfo:get_hasValueFlag() then
                        self:addErrMess( unwrapBlock:get_pos(), "This variable isn't set -- " .. (symbolInfo:get_name() ) )
                     end
                     
                  end
                  
               end
               
            end
            
         end
         
      end
      
      token = self:getToken( true )
      if token.txt == "then" then
         thenBlock = self:analyzeBlock( Nodes.BlockKind.LetUnwrap, TentativeMode.Finish, scope )
      else
       
         self:pushback(  )
         self:finishTentativeSymbol( true )
      end
      
   end
   
   local syncBlock = nil
   if mode == Nodes.DeclVarMode.Sync then
      self:checkNextToken( "do" )
      syncBlock = self:analyzeBlock( Nodes.BlockKind.LetUnwrap, TentativeMode.Simple, syncScope )
      self:popScope(  )
   end
   
   self:checkNextToken( ";" )
   local node = Nodes.DeclVarNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeNone}, mode, accessMode, false, varList, expList, symbolInfoList, typeInfoList, unwrapFlag, unwrapBlock, thenBlock, syncSymbolList, syncBlock )
   return node
end

function TransUnit:analyzeIfUnwrap( firstToken )

   local nextToken = self:getToken(  )
   local typeInfoList = {}
   local varNameList = {}
   local expList
   
   if nextToken.txt == "let" then
      local workTypeInfoList, letVarList, orgExpTypeList, workExpList = self:analyzeLetAndInitExp( firstToken.pos, Ast.MutMode.IMut, Ast.AccessMode.Local, true )
      typeInfoList = workTypeInfoList
      if workExpList ~= nil then
         expList = workExpList
      else
         self:addErrMess( nextToken.pos, "if! let has illegal init val." )
         self:error( "system error" )
      end
      
      for __index, varInfo in pairs( letVarList ) do
         table.insert( varNameList, varInfo.varName.txt )
      end
      
   else
    
      self:pushback(  )
      expList = self:analyzeExpList( false, false )
      local exp = expList:get_expList()[1]
      if exp:get_expType():get_nilable() then
         table.insert( typeInfoList, exp:get_expType():get_nonnilableType() )
      else
       
         table.insert( typeInfoList, exp:get_expType() )
      end
      
      table.insert( varNameList, "_exp" )
   end
   
   local scope = self:pushScope( false )
   for index, expType in pairs( typeInfoList ) do
      if index > #varNameList then
         break
      end
      
      local varName = varNameList[index]
      self:addLocalVar( firstToken.pos, false, true, varName, expType, Ast.MutMode.IMut )
   end
   
   local block = self:analyzeBlock( Nodes.BlockKind.IfUnwrap, TentativeMode.Start, scope )
   self:popScope(  )
   local elseBlock = nil
   nextToken = self:getToken( true )
   if nextToken.txt == "else" then
      elseBlock = self:analyzeBlock( Nodes.BlockKind.IfUnwrap, TentativeMode.Finish )
   else
    
      self:finishTentativeSymbol( false )
      self:pushback(  )
   end
   
   local hasCond = false
   for index, expNode in pairs( expList:get_expList() ) do
      if index ~= #expList:get_expList() then
         if Ast.isConditionalbe( expNode:get_expType() ) then
            hasCond = true
            break
         end
         
      else
       
         for __index, expType in pairs( expNode:get_expTypeList() ) do
            if Ast.isConditionalbe( expType ) then
               hasCond = true
               break
            end
            
         end
         
      end
      
   end
   
   if not hasCond then
      self:addErrMess( firstToken.pos, "This condition never be false" )
   end
   
   return Nodes.IfUnwrapNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeNone}, varNameList, expList, block, elseBlock )
end

function TransUnit:analyzeWhen( firstToken )

   local nextToken, continueFlag = self:getContinueToken(  )
   local varNameList = {}
   if not (continueFlag and nextToken.txt == "!" ) then
      self:pushback(  )
      self:addErrMess( nextToken.pos, "'when' need '!'" )
   end
   
   local symListNode = self:analyzeExpList( false, false )
   local scope = self:pushScope( false )
   local expNodeList = {}
   for __index, expNode in pairs( symListNode:get_expList() ) do
      table.insert( expNodeList, expNode )
      do
         local refNode = _lune.__Cast( expNode, 3, Nodes.ExpRefNode )
         if refNode ~= nil then
            if expNode:get_expType():get_nilable() then
               local symbolInfo = refNode:get_symbolInfo()
               table.insert( varNameList, refNode:get_token().txt )
               self:addLocalVar( firstToken.pos, false, expNode:canBeLeft(  ), refNode:get_token().txt, expNode:get_expType():get_nonnilableType(), symbolInfo:get_mutable() and Ast.MutMode.Mut or Ast.MutMode.IMut, true )
            else
             
               self:addErrMess( expNode:get_pos(), string.format( "This type isn't nilable. -- %s", expNode:get_expType():getTxt(  )) )
            end
            
         else
            self:addErrMess( expNode:get_pos(), "'when' support only local variables or arguments." )
         end
      end
      
   end
   
   local block = self:analyzeBlock( Nodes.BlockKind.IfUnwrap, TentativeMode.Start, scope )
   self:popScope(  )
   local elseBlock = nil
   nextToken = self:getToken( true )
   if nextToken.txt == "else" then
      elseBlock = self:analyzeBlock( Nodes.BlockKind.When, TentativeMode.Finish )
   else
    
      self:finishTentativeSymbol( false )
      self:pushback(  )
   end
   
   return Nodes.WhenNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeNone}, varNameList, expNodeList, block, elseBlock )
end

function TransUnit:createExpList( pos, expTypeList, expList, followOn, abbrNode )

   local workList = {}
   local mRetExp = nil
   if #expList > 0 then
      for index, exp in pairs( expList ) do
         if #exp:get_expTypeList() > 1 or exp:get_expType():get_kind() == Ast.TypeInfoKind.DDD then
            if index ~= #expList then
               table.insert( workList, Nodes.ExpMultiTo1Node.create( self.nodeManager, exp:get_pos(), {exp:get_expType()}, exp ) )
            else
             
               table.insert( workList, exp )
               if #exp:get_expTypeList() > 1 then
                  mRetExp = Nodes.MRetExp.new(exp, index)
                  for listIndex, expType in pairs( exp:get_expTypeList() ) do
                     if listIndex ~= 1 then
                        table.insert( expTypeList, expType )
                     end
                     
                  end
                  
                  for retIndex, retType in pairs( exp:get_expTypeList() ) do
                     if retIndex ~= 1 then
                        table.insert( workList, Nodes.ExpAccessMRetNode.create( self.nodeManager, exp:get_pos(), {retType}, exp, retIndex ) )
                     end
                     
                  end
                  
               end
               
            end
            
         else
          
            table.insert( workList, exp )
         end
         
      end
      
   end
   
   if abbrNode ~= nil then
      table.insert( workList, abbrNode )
   end
   
   return Nodes.ExpListNode.create( self.nodeManager, pos, expTypeList, workList, mRetExp, followOn )
end

function TransUnit:analyzeExpList( allowNoneType, skipOp2Flag, expNode, expectTypeList, contExpect )

   local expList = {}
   local pos = nil
   local expTypeList = {}
   if expNode ~= nil then
      pos = expNode:get_pos()
      table.insert( expList, expNode )
      table.insert( expTypeList, expNode:get_expType() )
   end
   
   local index = 1
   local abbrNode = nil
   local mRetExp = nil
   local followOn = false
   repeat 
      local expectType = nil
      if expectTypeList ~= nil then
         if #expectTypeList > 0 then
            local checkIndex = index
            if index > #expectTypeList and contExpect then
               checkIndex = #expectTypeList
            end
            
            if checkIndex <= #expectTypeList and expectTypeList[checkIndex] ~= Ast.builtinTypeNone then
               expectType = expectTypeList[checkIndex]
            end
            
         end
         
      end
      
      local exp = self:analyzeExp( allowNoneType, skipOp2Flag, 0, expectType )
      if not allowNoneType and not exp:canBeRight(  ) then
         self:addErrMess( exp:get_pos(), string.format( "This arg can't be r-value. -- %s", Nodes.getNodeKindName( exp:get_kind() )) )
      end
      
      if not pos then
         pos = exp:get_pos()
      end
      
      table.insert( expList, exp )
      table.insert( expTypeList, exp:get_expType() )
      local token = self:getToken(  )
      if token.txt == "**" then
         if #exp:get_expTypeList() <= 1 then
            self:addErrMess( exp:get_pos(), string.format( "This arg(%d) doesn't have multiple value. It must not use '**'", index) )
         end
         
         followOn = true
         token = self:getToken(  )
      end
      
      if token.txt == "##" then
         if exp:get_expType():get_kind() == Ast.TypeInfoKind.DDD then
            self:addErrMess( token.pos, "'##' can't use with '...'" )
         end
         
         abbrNode = Nodes.AbbrNode.create( self.nodeManager, token.pos, {Ast.builtinTypeAbbr} )
         self:getToken(  )
         break
      end
      
      index = index + 1
   until token.txt ~= ","
   local expListNode = self:createExpList( _lune.unwrapDefault( pos, Parser.Position.new(0, 0)), expTypeList, expList, followOn, abbrNode )
   if not allowNoneType then
      for expIndex, expType in pairs( expTypeList ) do
         if expType == Ast.builtinTypeNone then
            self:addErrMess( _lune.unwrapDefault( pos, Parser.Position.new(0, 0)), string.format( "The type of exp(%d) is None!!", expIndex) )
         end
         
      end
      
   end
   
   self:pushback(  )
   return expListNode
end

function TransUnit:analyzeListConst( token )

   local nextToken = self:getToken(  )
   local expList = nil
   local itemTypeInfo = Ast.builtinTypeNone
   if nextToken.txt ~= "]" then
      self:pushback(  )
      expList = self:analyzeExpList( false, false )
      self:checkNextToken( "]" )
      local nodeList = (_lune.unwrap( expList) ):get_expList()
      for __index, exp in pairs( nodeList ) do
         itemTypeInfo = Ast.TypeInfo.getCommonType( itemTypeInfo, exp:get_expType(), Ast.CanEvalCtrlTypeInfo.createDefaultAlt2typeMap( false ) )
      end
      
   end
   
   if itemTypeInfo:get_kind() == Ast.TypeInfoKind.DDD then
      if #itemTypeInfo:get_itemTypeInfoList() > 0 then
         itemTypeInfo = itemTypeInfo:get_itemTypeInfoList()[1]
      else
       
         itemTypeInfo = Ast.builtinTypeStem_
      end
      
   end
   
   local typeInfoList = {Ast.builtinTypeNone}
   if token.txt == '[' then
      typeInfoList = {Ast.NormalTypeInfo.createList( Ast.AccessMode.Local, self:getCurrentClass(  ), {itemTypeInfo}, Ast.MutMode.Mut )}
      return Nodes.LiteralListNode.create( self.nodeManager, token.pos, typeInfoList, expList )
   else
    
      typeInfoList = {Ast.NormalTypeInfo.createArray( Ast.AccessMode.Local, self:getCurrentClass(  ), {itemTypeInfo}, Ast.MutMode.Mut )}
      return Nodes.LiteralArrayNode.create( self.nodeManager, token.pos, typeInfoList, expList )
   end
   
end

function TransUnit:analyzeSetConst( token )

   self.helperInfo.useSet = true
   local nextToken = self:getToken(  )
   local expList = nil
   local itemTypeInfo = Ast.builtinTypeNone
   if nextToken.txt ~= ")" then
      self:pushback(  )
      expList = self:analyzeExpList( false, false )
      self:checkNextToken( ")" )
      local nodeList = (_lune.unwrap( expList) ):get_expList()
      for __index, exp in pairs( nodeList ) do
         local expType = exp:get_expType()
         if expType:get_nilable() then
            self:addErrMess( exp:get_pos(), string.format( "'Set' object can't store nilable. -- %s", expType:getTxt(  )) )
         else
          
            itemTypeInfo = Ast.TypeInfo.getCommonType( itemTypeInfo, exp:get_expType(), Ast.CanEvalCtrlTypeInfo.createDefaultAlt2typeMap( false ) )
         end
         
      end
      
   end
   
   local typeInfoList = {Ast.builtinTypeNone}
   typeInfoList = {Ast.NormalTypeInfo.createSet( Ast.AccessMode.Local, self:getCurrentClass(  ), {itemTypeInfo}, Ast.MutMode.Mut )}
   return Nodes.LiteralSetNode.create( self.nodeManager, token.pos, typeInfoList, expList )
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
         
         expType = expType:get_nonnilableType()
      end
      
      return Ast.TypeInfo.getCommonType( typeInfo, expType, Ast.CanEvalCtrlTypeInfo.createDefaultAlt2typeMap( false ) )
   end
   
   while true do
      if nextToken.txt == "}" then
         break
      end
      
      self:pushback(  )
      local key = self:analyzeExp( false, false )
      keyTypeInfo = getMapKeyValType( key:get_pos(), true, keyTypeInfo, key:get_expType() )
      self:checkNextToken( ":" )
      local val = self:analyzeExp( false, false )
      valTypeInfo = getMapKeyValType( val:get_pos(), false, valTypeInfo, val:get_expType() )
      table.insert( pairList, Nodes.PairItem.new(key, val) )
      map[key] = val
      nextToken = self:getToken(  )
      if nextToken.txt ~= "," then
         break
      end
      
      nextToken = self:getToken(  )
   end
   
   local typeInfo = Ast.NormalTypeInfo.createMap( Ast.AccessMode.Local, self:getCurrentClass(  ), keyTypeInfo, valTypeInfo, Ast.MutMode.Mut )
   self:checkToken( nextToken, "}" )
   return Nodes.LiteralMapNode.create( self.nodeManager, token.pos, {typeInfo}, map, pairList )
end

function TransUnit:checkSymbolHavingValue( pos, symbolInfoList )

   for __index, symbolInfo in pairs( symbolInfoList ) do
      if symbolInfo:get_kind() == Ast.SymbolKind.Var then
         if not symbolInfo:get_hasValueFlag() then
            self:addErrMess( pos, string.format( "this variable have no value. -- %s", symbolInfo:get_name()) )
         end
         
      end
      
   end
   
end

function TransUnit:analyzeExpRefItem( token, exp, nilAccess )

   self:checkSymbolHavingValue( exp:get_pos(), exp:getSymbolInfo(  ) )
   local expType = exp:get_expType()
   if nilAccess then
      if not expType:get_nilable() then
         nilAccess = false
      else
       
         expType = expType:get_nonnilableType()
      end
      
   end
   
   local expectItemType = nil
   local typeInfo = Ast.builtinTypeStem_
   local indexTypeInfo = Ast.builtinTypeInt
   if expType:get_kind() == Ast.TypeInfoKind.Map then
      local itemTypeList = expType:get_itemTypeInfoList(  )
      typeInfo = itemTypeList[2]
      indexTypeInfo = itemTypeList[1]
      expectItemType = itemTypeList[1]
      if not typeInfo:equals( Ast.builtinTypeStem_ ) and not typeInfo:get_nilable() then
         typeInfo = typeInfo:get_nilableTypeInfo()
      end
      
   elseif expType:get_kind() == Ast.TypeInfoKind.Array or expType:get_kind() == Ast.TypeInfoKind.List then
      typeInfo = expType:get_itemTypeInfoList(  )[1]
   elseif expType:equals( Ast.builtinTypeString ) then
      typeInfo = Ast.builtinTypeInt
   elseif expType:equals( Ast.builtinTypeStem ) then
      indexTypeInfo = Ast.builtinTypeStem
      typeInfo = Ast.builtinTypeStem_
   else
    
      self:addErrMess( exp:get_pos(), string.format( "could not access with []. -- %s", expType:getTxt(  )) )
   end
   
   if nilAccess then
      self.helperInfo.useNilAccess = true
      if not typeInfo:get_nilable() then
         typeInfo = typeInfo:get_nilableTypeInfo()
      end
      
   end
   
   if Ast.TypeInfo.isMut( typeInfo ) then
      if expType:get_mutMode() == Ast.MutMode.IMutRe then
         typeInfo = self:createModifier( typeInfo, Ast.MutMode.IMutRe )
      end
      
   end
   
   local indexExp = self:analyzeExp( false, false, nil, expectItemType )
   if not indexExp:canBeRight(  ) then
      self:addErrMess( indexExp:get_pos(), "This node can't use index" )
   end
   
   if not indexTypeInfo:canEvalWith( indexExp:get_expType(), Ast.CanEvalType.SetOp, {} ) then
      self:addErrMess( indexExp:get_pos(), string.format( "unmatch index type -- %s, %s", indexTypeInfo:getTxt(  ), indexExp:get_expType():getTxt(  )) )
   end
   
   self:checkNextToken( "]" )
   return Nodes.ExpRefItemNode.create( self.nodeManager, token.pos, {typeInfo}, exp, nilAccess, nil, indexExp )
end


function TransUnit:checkImplicitCast( alt2typeMap, dstTypeList, expListNode, callback )

   local expNodeList = expListNode:get_expList()
   local hasModNode = false
   local newExpNodeList = {}
   local expTypeList = {}
   for index, expNode in pairs( expNodeList ) do
      local workNode = expNode
      local stopFlag = false
      if #dstTypeList >= index then
         local dstType = dstTypeList[index]
         do
            local repNode = callback( dstType, expNode )
            if repNode ~= nil then
               if not hasModNode then
                  hasModNode = true
               end
               
               workNode = repNode
            else
               if dstType ~= Ast.builtinTypeEmpty and not dstType:equals( expNode:get_expType() ) and not dstType:get_nonnilableType():equals( expNode:get_expType() ) then
                  if expNode:get_kind() ~= Nodes.NodeKind.get_Abbr() then
                     if not hasModNode then
                        hasModNode = true
                     end
                     
                     if dstType:get_kind() == Ast.TypeInfoKind.DDD then
                        local argList = {}
                        local argTypeList = {}
                        for workIndex = index, #expNodeList do
                           local appNode = expNodeList[workIndex]
                           table.insert( argList, appNode )
                        end
                        
                        local mRetExp
                        
                        do
                           local workMRetExp = expListNode:get_mRetExp()
                           if workMRetExp ~= nil then
                              mRetExp = Nodes.MRetExp.new(workMRetExp:get_exp(), workMRetExp:get_index() - index + 1)
                           else
                              mRetExp = nil
                           end
                        end
                        
                        local newExpListNode = Nodes.ExpListNode.create( self.nodeManager, expNode:get_pos(), argTypeList, argList, mRetExp, expListNode:get_followOn() )
                        workNode = Nodes.ExpToDDDNode.create( self.nodeManager, expNode:get_pos(), {dstType}, newExpListNode )
                        stopFlag = true
                     else
                      
                        local castType = alt2typeMap[dstType]
                        if  nil == castType then
                           local _castType = castType
                        
                           castType = dstType
                        end
                        
                        workNode = Nodes.ExpCastNode.create( self.nodeManager, expNode:get_pos(), {expNode:get_expType()}, expNode, castType, Nodes.CastKind.Implicit )
                     end
                     
                  end
                  
               end
               
            end
         end
         
      end
      
      table.insert( newExpNodeList, workNode )
      table.insert( expTypeList, workNode:get_expType() )
      if stopFlag then
         break
      end
      
   end
   
   if not hasModNode then
      return nil
   end
   
   local newMRetExp = nil
   do
      local mRetExp = expListNode:get_mRetExp()
      if mRetExp ~= nil then
         if mRetExp:get_index() <= #newExpNodeList and newExpNodeList[mRetExp:get_index()]:get_expType():get_kind() ~= Ast.TypeInfoKind.DDD then
            newMRetExp = mRetExp
         end
         
      end
   end
   
   return Nodes.ExpListNode.create( self.nodeManager, expListNode:get_pos(), expTypeList, newExpNodeList, newMRetExp, expListNode:get_followOn() )
end

function TransUnit:checkMatchType( message, pos, dstTypeList, expListNode, allowDstShort, warnForFollow, genericsClassType )

   local expNodeList = _lune.nilacc( expListNode, 'get_expList', 'callmtd' )
   if  nil == expNodeList then
      local _expNodeList = expNodeList
   
      expNodeList = {}
   end
   
   local warnForFollowSrcIndex = nil
   local expTypeList = {}
   local workExpNodeList = expNodeList
   local hasAbbr = false
   if #expNodeList > 0 then
      if expNodeList[#expNodeList]:get_kind() == Nodes.NodeKind.get_Abbr() then
         hasAbbr = true
         local workList = {}
         for index, node in pairs( expNodeList ) do
            table.insert( workList, node )
         end
         
         table.remove( workList )
         workExpNodeList = workList
      end
      
   end
   
   local realExpNum = -1
   for index, expNode in pairs( workExpNodeList ) do
      if realExpNum == -1 and expNode:get_kind() == Nodes.NodeKind.get_ExpAccessMRet() then
         realExpNum = index - 1
      end
      
      if index == #workExpNodeList then
         for __index, expType in pairs( expNode:get_expTypeList() ) do
            table.insert( expTypeList, expType )
         end
         
      else
       
         table.insert( expTypeList, expNode:get_expType() )
      end
      
   end
   
   if realExpNum == -1 then
      realExpNum = #workExpNodeList
   end
   
   if warnForFollow and #expTypeList > realExpNum then
      warnForFollowSrcIndex = realExpNum + 1
   end
   
   if hasAbbr then
      table.insert( expTypeList, Ast.builtinTypeAbbr )
   end
   
   local alt2typeMap = Ast.CanEvalCtrlTypeInfo.createDefaultAlt2typeMap( false )
   if genericsClassType ~= nil then
      alt2typeMap = genericsClassType:createAlt2typeMap( true )
   end
   
   Ast.CanEvalCtrlTypeInfo.setupNeedAutoBoxing( alt2typeMap )
   local result, mess = Ast.TypeInfo.checkMatchType( dstTypeList, expTypeList, allowDstShort, warnForFollowSrcIndex, alt2typeMap )
   do
      local _switchExp = result
      if _switchExp == Ast.MatchType.Error then
         self:addErrMess( pos, string.format( "%s: %s", message, mess) )
      elseif _switchExp == Ast.MatchType.Warn then
         if not self.ctrl_info.checkingDefineAbbr and Code.isMessageOf( Code.ID.nothing_define_abbr, mess ) then
         else
          
            self:addWarnMess( pos, string.format( "%s: %s", message, mess) )
         end
         
      end
   end
   
   if expListNode ~= nil then
      local autoBoxingCount = 0
      local hasImplictCast = false
      local newExpListNode
      
      do
         local workList = self:checkImplicitCast( alt2typeMap, dstTypeList, expListNode, function ( dstType, expNode )
         
            if Ast.CanEvalCtrlTypeInfo.canAutoBoxing( dstType, expNode:get_expType() ) then
               autoBoxingCount = autoBoxingCount + 1
               return Nodes.BoxingNode.create( self.nodeManager, expNode:get_pos(), {dstType}, expNode )
            end
            
            return nil
         end
          )
         if workList ~= nil then
            newExpListNode = workList
            hasImplictCast = true
         else
            newExpListNode = nil
         end
      end
      
      if autoBoxingCount > 0 then
         if not Ast.CanEvalCtrlTypeInfo.finishNeedAutoBoxing( alt2typeMap, autoBoxingCount ) then
            self:addErrMess( pos, string.format( "illegal auto boxing error -- %d", autoBoxingCount) )
         end
         
         return alt2typeMap, newExpListNode, expTypeList
      elseif Ast.CanEvalCtrlTypeInfo.hasNeedAutoBoxing( alt2typeMap ) then
         self:addErrMess( pos, "not support auto boxing" )
      end
      
      if hasImplictCast then
         return alt2typeMap, newExpListNode, expTypeList
      end
      
   end
   
   if not Ast.CanEvalCtrlTypeInfo.finishNeedAutoBoxing( alt2typeMap, 0 ) then
      self:addErrMess( pos, "can't auto boxing error" )
   end
   
   return alt2typeMap, nil, expTypeList
end

function TransUnit:checkMatchValType( pos, funcTypeInfo, expList, genericTypeList, genericsClass )

   local argTypeList = funcTypeInfo:get_argTypeInfoList()
   do
      local _switchExp = funcTypeInfo
      if _switchExp == builtinFunc.list_insert or _switchExp == builtinFunc.set_add or _switchExp == builtinFunc.set_del then
         argTypeList = genericTypeList
      elseif _switchExp == builtinFunc.list_sort then
         local alt2typeMap = Ast.CanEvalCtrlTypeInfo.createDefaultAlt2typeMap( false )
         local callback = Ast.NormalTypeInfo.createFunc( false, false, nil, Ast.TypeInfoKind.Func, Ast.headTypeInfo, false, false, true, Ast.AccessMode.Pri, "sort", nil, {genericTypeList[1], genericTypeList[1]}, {Ast.builtinTypeBool}, false )
         argTypeList = {callback:get_nilableTypeInfo()}
      elseif _switchExp == builtinFunc.list_remove then
      end
   end
   
   local warnForFollow = true
   if expList ~= nil then
      if expList:get_followOn() then
         warnForFollow = false
      end
      
   end
   
   local alt2typeMap, newExpNodeList = self:checkMatchType( funcTypeInfo:getTxt(  ), pos, argTypeList, expList, false, warnForFollow, genericsClass )
   if expList ~= nil and newExpNodeList ~= nil then
      return alt2typeMap, newExpNodeList
   end
   
   return alt2typeMap, expList
end

local MacroPaser = {}
setmetatable( MacroPaser, { __index = Parser.Parser } )
function MacroPaser.new( tokenList, name )
   local obj = {}
   MacroPaser.setmeta( obj )
   if obj.__init then obj:__init( tokenList, name ); end
   return obj
end
function MacroPaser:__init(tokenList, name) 
   Parser.Parser.__init( self)
   
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
function MacroPaser.setmeta( obj )
  setmetatable( obj, { __index = MacroPaser  } )
end

function TransUnit:evalMacroOp( firstToken, macroTypeInfo, expList, evalMacroCallback )

   local function getLiteralMacroVal( obj )
   
      do
         local _matchExp = obj
         if _matchExp[1] == Nodes.Literal.Nil[1] then
         
            return nil
         elseif _matchExp[1] == Nodes.Literal.Int[1] then
            local val = _matchExp[2][1]
         
            return val
         elseif _matchExp[1] == Nodes.Literal.Real[1] then
            local val = _matchExp[2][1]
         
            return val
         elseif _matchExp[1] == Nodes.Literal.Str[1] then
            local val = _matchExp[2][1]
         
            return val
         elseif _matchExp[1] == Nodes.Literal.Bool[1] then
            local val = _matchExp[2][1]
         
            return val
         elseif _matchExp[1] == Nodes.Literal.Symbol[1] then
            local val = _matchExp[2][1]
         
            return {val}
         elseif _matchExp[1] == Nodes.Literal.Field[1] then
            local val = _matchExp[2][1]
         
            return val
         elseif _matchExp[1] == Nodes.Literal.LIST[1] then
            local list = _matchExp[2][1]
         
            local newList = {}
            for index, item in pairs( list ) do
               newList[index] = getLiteralMacroVal( item )
            end
            
            return newList
         elseif _matchExp[1] == Nodes.Literal.ARRAY[1] then
            local list = _matchExp[2][1]
         
            local newList = {}
            for index, item in pairs( list ) do
               newList[index] = getLiteralMacroVal( item )
            end
            
            return newList
         elseif _matchExp[1] == Nodes.Literal.SET[1] then
            local list = _matchExp[2][1]
         
            local newSet = {}
            for __index, item in pairs( list ) do
               do
                  local _exp = getLiteralMacroVal( item )
                  if _exp ~= nil then
                     newSet[_exp]= true
                  end
               end
               
            end
            
            return newSet
         elseif _matchExp[1] == Nodes.Literal.MAP[1] then
            local map = _matchExp[2][1]
         
            local newMap = {}
            for key, val in pairs( map ) do
               local keyObj = getLiteralMacroVal( key )
               local valObj = getLiteralMacroVal( val )
               if keyObj ~= nil and valObj ~= nil then
                  newMap[keyObj] = valObj
               end
               
            end
            
            return newMap
         end
      end
      
      Util.err( "unknown literal obj -- " .. Nodes.Literal:_getTxt( obj)
       )
   end
   
   self.useModuleMacroSet[macroTypeInfo:getModule(  )]= true
   if expList ~= nil then
      for __index, exp in pairs( expList:get_expList(  ) ) do
         local kind = exp:get_kind()
         do
            local _switchExp = kind
            if _switchExp == Nodes.NodeKind.get_LiteralNil() or _switchExp == Nodes.NodeKind.get_LiteralChar() or _switchExp == Nodes.NodeKind.get_LiteralInt() or _switchExp == Nodes.NodeKind.get_LiteralReal() or _switchExp == Nodes.NodeKind.get_LiteralArray() or _switchExp == Nodes.NodeKind.get_LiteralList() or _switchExp == Nodes.NodeKind.get_LiteralMap() or _switchExp == Nodes.NodeKind.get_LiteralString() or _switchExp == Nodes.NodeKind.get_LiteralBool() or _switchExp == Nodes.NodeKind.get_LiteralSymbol() or _switchExp == Nodes.NodeKind.get_RefField() or _switchExp == Nodes.NodeKind.get_ExpMacroStat() or _switchExp == Nodes.NodeKind.get_ExpOmitEnum() or _switchExp == Nodes.NodeKind.get_ExpCast() then
            else 
               
                  self:error( string.format( "Macro arguments must be literal value. -- %d:%d:%s", exp:get_pos().lineNo, exp:get_pos().column, Nodes.getNodeKindName( kind )) )
            end
         end
         
      end
      
   end
   
   local macroInfo = _lune.unwrap( self.typeId2MacroInfo[macroTypeInfo:get_typeId(  )])
   local argValMap = {}
   local macroArgValMap = {}
   local macroArgNodeList = macroInfo:getArgList(  )
   local macroArgName2ArgNode = {}
   if expList ~= nil then
      for index, argNode in pairs( expList:get_expList(  ) ) do
         local literal = argNode:getLiteral(  )
         if literal ~= nil then
            do
               local val = getLiteralMacroVal( literal )
               if val ~= nil then
                  argValMap[index] = val
                  local declArgNode = macroArgNodeList[index]
                  macroArgValMap[declArgNode:get_name()] = val
                  macroArgName2ArgNode[declArgNode:get_name()] = argNode
               end
            end
            
         end
         
      end
      
   end
   
   local func = macroInfo.func
   local macroVars = {}
   do
      local macroRet = func( macroArgValMap )
      if macroRet ~= nil then
         macroVars = macroRet
      end
   end
   
   for __index, name in pairs( (_lune.unwrap( macroVars['__names']) ) ) do
      local valInfo = _lune.unwrap( macroInfo.symbol2MacroValInfoMap[name])
      local typeInfo = valInfo.typeInfo or Ast.builtinTypeStem_
      local val = macroVars[name]
      if typeInfo:equals( Ast.builtinTypeSymbol ) then
         val = {val}
      end
      
      self.symbol2ValueMapForMacro[name] = Nodes.MacroValInfo.new(val, typeInfo, macroArgName2ArgNode[name])
   end
   
   for index, arg in pairs( macroInfo:getArgList(  ) ) do
      if arg:get_typeInfo():get_kind() ~= Ast.TypeInfoKind.DDD then
         local argType = arg:get_typeInfo()
         local argName = arg:get_name()
         self.symbol2ValueMapForMacro[argName] = Nodes.MacroValInfo.new(argValMap[index], argType, macroArgName2ArgNode[argName])
      else
       
         self:error( "not support ... in macro" )
      end
      
   end
   
   local parser = MacroPaser.new(macroInfo:getTokenList(  ), string.format( "%s:%d(macro %s)", self.parser:getStreamName(  ), firstToken.pos.lineNo, macroTypeInfo:getTxt(  )))
   local bakParser = self.parser
   self.parser = parser
   self.macroMode = Nodes.MacroMode.Expand
   self.macroCallLineNo = firstToken.pos.lineNo
   evalMacroCallback(  )
   self.macroMode = Nodes.MacroMode.None
   self.parser = bakParser
end

function TransUnit:evalMacro( firstToken, macroTypeInfo, expList )

   local stmtList = {}
   self:evalMacroOp( firstToken, macroTypeInfo, expList, function (  )
   
      self:analyzeStatementList( stmtList, "}" )
   end
    )
   return Nodes.ExpMacroExpNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeNone}, stmtList )
end

local function findForm( format )

   local remain = format
   local opList = {}
   while true do
      local pos, endPos = nil, nil
      do
         local index, endIndex = remain:find( "^%%[%d]*%a" )
         if index ~= nil and endIndex ~= nil then
            pos, endPos = index, endIndex
         else
            do
               local index, endIndex = remain:find( "[^%%]%%[%d]*%a" )
               if index ~= nil and endIndex ~= nil then
                  pos, endPos = index + 1, endIndex
               end
            end
            
         end
      end
      
      if pos ~= nil and endPos ~= nil then
         local op = remain:sub( pos, endPos )
         table.insert( opList, op )
         remain = remain:sub( endPos + 1 )
      else
         break
      end
      
   end
   
   return opList
end
_moduleObj.findForm = findForm
local FormType = {}
_moduleObj.FormType = FormType
FormType._val2NameMap = {}
function FormType:_getTxt( val )
   local name = self._val2NameMap[ val ]
   if name then
      return string.format( "FormType.%s", name )
   end
   return string.format( "illegal val -- %s", val )
end
function FormType._from( val )
   if FormType._val2NameMap[ val ] then
      return val
   end
   return nil
end
    
FormType.__allList = {}
function FormType.get__allList()
   return FormType.__allList
end

FormType.Match = 0
FormType._val2NameMap[0] = 'Match'
FormType.__allList[1] = FormType.Match
FormType.NeedConv = 1
FormType._val2NameMap[1] = 'NeedConv'
FormType.__allList[2] = FormType.NeedConv
FormType.Unmatch = 2
FormType._val2NameMap[2] = 'Unmatch'
FormType.__allList[3] = FormType.Unmatch

local function isMatchStringFormatType( opKind, argType, luaVer )

   do
      local enumType = _lune.__Cast( argType:get_srcTypeInfo(), 3, Ast.EnumTypeInfo )
      if enumType ~= nil then
         argType = enumType:get_valTypeInfo()
      end
   end
   
   do
      local _switchExp = string.byte( opKind, #opKind )
      if _switchExp == 115 then
         if not argType:equals( Ast.builtinTypeString ) then
            if not luaVer:get_canFormStem2Str() then
               return FormType.NeedConv, Ast.builtinTypeString
            end
            
         end
         
      elseif _switchExp == 113 then
         if not argType:equals( Ast.builtinTypeString ) then
            return FormType.Unmatch, Ast.builtinTypeString
         end
         
      elseif _switchExp == 65 or _switchExp == 97 or _switchExp == 69 or _switchExp == 101 or _switchExp == 102 or _switchExp == 71 or _switchExp == 103 then
         if not argType:equals( Ast.builtinTypeReal ) then
            return FormType.Unmatch, Ast.builtinTypeReal
         end
         
      else 
         
            if not argType:equals( Ast.builtinTypeInt ) and not argType:equals( Ast.builtinTypeChar ) then
               return FormType.Unmatch, Ast.builtinTypeInt
            end
            
      end
   end
   
   return FormType.Match, Ast.builtinTypeNone
end
_moduleObj.isMatchStringFormatType = isMatchStringFormatType
function TransUnit:checkStringFormat( pos, formatTxt, argTypeList )

   local opList = findForm( formatTxt )
   local dstTypeList = {}
   if #opList ~= #argTypeList then
      self:addErrMess( pos, string.format( "argument number is mismatch -- %d != %d", #opList, #argTypeList) )
      return 
   end
   
   for index, op in pairs( opList ) do
      local argType = argTypeList[index]
      local match, reqType = isMatchStringFormatType( op, argType, self.targetLuaVer )
      if match == FormType.Unmatch then
         local mess = string.format( "type must be %s -- %s", reqType:getTxt(  ), argType:getTxt(  ))
         self:addErrMess( pos, string.format( "argument(%d) %s", index, mess) )
      end
      
   end
   
end

function TransUnit:prepareExpCall( position, funcTypeInfo, genericTypeList, genericsClass )

   local macroFlag = false
   if funcTypeInfo:get_kind(  ) == Ast.TypeInfoKind.Macro then
      macroFlag = true
      self.symbol2ValueMapForMacro = {}
      self.macroMode = Nodes.MacroMode.Analyze
   end
   
   local work = self:getToken(  )
   local argList = nil
   if work.txt ~= ")" then
      self:pushback(  )
      argList = self:analyzeExpList( false, false, nil, funcTypeInfo:get_argTypeInfoList() )
      self:checkNextToken( ")" )
      if argList ~= nil then
         for __index, argNode in pairs( argList:get_expList() ) do
            if not argNode:canBeRight(  ) and argNode:get_kind() ~= Nodes.NodeKind.get_Abbr() then
               self:addErrMess( argNode:get_pos(), string.format( "this node can't be r-value. -- %s", Nodes.getNodeKindName( argNode:get_kind() )) )
            end
            
         end
         
      end
      
   end
   
   local alt2typeMap, workArgList = self:checkMatchValType( position, funcTypeInfo, argList, genericTypeList, genericsClass )
   return alt2typeMap, workArgList
end

function TransUnit:analyzeExpCall( firstToken, exp, nextToken )

   self:checkSymbolHavingValue( exp:get_pos(), exp:getSymbolInfo(  ) )
   local function checkArgForStringForm( argList )
   
      local formArgTypeList = {}
      local formatTxt = ""
      if #argList:get_expList() > 0 then
         local argNode = argList:get_expList()[1]
         if argNode:get_kind() ~= Nodes.NodeKind.get_LiteralString() then
            return 
         end
         
         do
            local literal = argNode:getLiteral(  )
            if literal ~= nil then
               do
                  local _matchExp = literal
                  if _matchExp[1] == Nodes.Literal.Str[1] then
                     local val = _matchExp[2][1]
                  
                     formatTxt = val
                  end
               end
               
            end
         end
         
      end
      
      if #argList:get_expList() > 1 then
         do
            local toDDDNode = _lune.__Cast( argList:get_expList()[2], 3, Nodes.ExpToDDDNode )
            if toDDDNode ~= nil then
               for index, workNode in pairs( toDDDNode:get_expList():get_expList() ) do
                  table.insert( formArgTypeList, workNode:get_expType() )
               end
               
            end
         end
         
      end
      
      self:checkStringFormat( firstToken.pos, formatTxt, formArgTypeList )
   end
   
   local function checkArgForSort( genericTypeList, argList )
   
      if #argList:get_expTypeList() > 0 then
         local callback = argList:get_expTypeList()[1]
         if callback == Ast.builtinTypeAbbr then
            return 
         end
         
         if #callback:get_retTypeInfoList() ~= 1 then
            self:addErrMess( firstToken.pos, string.format( "The callback's to return value of sort() must have a value. -- %d", #callback:get_retTypeInfoList()) )
            return 
         end
         
         if not Ast.builtinTypeBool:equals( callback:get_retTypeInfoList()[1] ) then
            self:addErrMess( firstToken.pos, string.format( "The callback's return type of sort() must be bool. -- '%s'", callback:get_retTypeInfoList()[1]:getTxt(  )) )
         end
         
         if #callback:get_argTypeInfoList() ~= 2 then
            self:addErrMess( firstToken.pos, string.format( "The callback's argument must have 2 arguments. -- '%s'", callback:get_display_stirng()) )
         end
         
         if #genericTypeList == 1 then
            for index, argType in pairs( callback:get_argTypeInfoList() ) do
               if not genericTypeList[1]:equals( argType ) then
                  self:addErrMess( firstToken.pos, string.format( "The callback's argument(%d) type must be -- '%s'", index, genericTypeList[1]:getTxt(  )) )
               end
               
            end
            
         else
          
            self:addErrMess( firstToken.pos, "The generics of the list is illegal" )
         end
         
      end
      
   end
   
   local funcTypeInfo = exp:get_expType()
   local nilAccess
   
   if nextToken.txt == "$(" and funcTypeInfo:get_nilable() then
      funcTypeInfo = funcTypeInfo:get_nonnilableType()
      nilAccess = true
   else
    
      nilAccess = false
   end
   
   local genericTypeList = funcTypeInfo:get_itemTypeInfoList()
   local refFieldNode = nil
   local genericsClass = Ast.headTypeInfo
   do
      local refField = _lune.__Cast( exp, 3, Nodes.RefFieldNode )
      if refField ~= nil then
         refFieldNode = refField
         local classType = refField:get_prefix():get_expType()
         genericsClass = classType
         if funcTypeInfo:get_kind() == Ast.TypeInfoKind.Method then
            genericTypeList = classType:get_itemTypeInfoList()
         end
         
      end
   end
   
   local alt2typeMap, argList = self:prepareExpCall( exp:get_pos(), funcTypeInfo, genericTypeList, genericsClass )
   if funcTypeInfo:equals( builtinFunc.list_insert ) then
      if argList ~= nil then
         if argList:get_expType():get_nilable() then
            self:addErrMess( argList:get_pos(), "list can't insert nilable" )
         end
         
      end
      
   end
   
   if funcTypeInfo:equals( builtinFunc.set_add ) then
      if argList ~= nil then
         if argList:get_expType():get_nilable() then
            self:addErrMess( argList:get_pos(), "set can't add nilable" )
         end
         
      end
      
   elseif funcTypeInfo:equals( builtinFunc.list_remove ) then
      if #genericTypeList > 0 then
         if genericTypeList[1]:get_nilable() then
            self:addWarnMess( exp:get_pos(), "remove() is dangerous for nilable's list." )
         end
         
      end
      
   end
   
   if funcTypeInfo:get_kind(  ) == Ast.TypeInfoKind.Macro then
      self.macroMode = Nodes.MacroMode.None
      exp = self:evalMacro( firstToken, funcTypeInfo, argList )
   else
    
      do
         local _switchExp = (funcTypeInfo:get_kind() )
         if _switchExp == Ast.TypeInfoKind.Method or _switchExp == Ast.TypeInfoKind.Func or _switchExp == Ast.TypeInfoKind.Form or _switchExp == Ast.TypeInfoKind.FormFunc then
         else 
            
               self:error( string.format( "can't call the type -- %s, %s", funcTypeInfo:getTxt(  ), Ast.TypeInfoKind:_getTxt( funcTypeInfo:get_kind())
               ) )
         end
      end
      
      local retTypeInfoList = {}
      for index, retType in pairs( funcTypeInfo:get_retTypeInfoList() ) do
         table.insert( retTypeInfoList, retType )
         do
            local applyType = retType:applyGeneric( alt2typeMap, self.moduleType )
            if applyType ~= nil then
               retTypeInfoList[index] = applyType
            else
               if funcTypeInfo == builtinFunc.list_remove then
                  retTypeInfoList[index] = genericTypeList[1]:get_nilableTypeInfo()
               elseif funcTypeInfo:get_kind() == Ast.TypeInfoKind.Func and (funcTypeInfo:get_rawTxt() == "_fromMap" or funcTypeInfo:get_rawTxt() == "_fromStem" ) and genericsClass:isInheritFrom( Ast.builtinTypeMapping, alt2typeMap ) then
                  retTypeInfoList[index] = genericsClass:get_nilableTypeInfo()
               else
                
                  self:addErrMess( firstToken.pos, string.format( "not support generics yet. -- %s", retType:getTxt(  )) )
               end
               
            end
         end
         
      end
      
      if refFieldNode ~= nil then
         if funcTypeInfo:equals( builtinFunc.list_unpack ) or funcTypeInfo:equals( builtinFunc.array_unpack ) then
            local prefixType = refFieldNode:get_prefix():get_expType()
            if #prefixType:get_itemTypeInfoList() > 0 then
               local dddType = Ast.NormalTypeInfo.createDDD( prefixType:get_itemTypeInfoList()[1], false )
               retTypeInfoList = {dddType}
            end
            
         end
         
      end
      
      if nilAccess then
         local retList = {}
         for __index, retType in pairs( retTypeInfoList ) do
            if retType:get_nilable() then
               table.insert( retList, retType )
            else
             
               table.insert( retList, retType:get_nilableTypeInfo() )
            end
            
         end
         
         retTypeInfoList = retList
         self.helperInfo.useNilAccess = true
      end
      
      local errorFuncFlag = false
      if #retTypeInfoList > 0 then
         local retType = retTypeInfoList[1]
         if retType == Ast.builtinTypeNeverRet then
            errorFuncFlag = true
         end
         
      end
      
      if argList ~= nil then
         do
            local _switchExp = funcTypeInfo
            if _switchExp == builtinFunc.string_format then
               checkArgForStringForm( argList )
            elseif _switchExp == builtinFunc.list_sort or _switchExp == builtinFunc.array_sort then
               checkArgForSort( genericTypeList, argList )
            end
         end
         
      end
      
      if funcTypeInfo:equals( builtinFunc.lune__kind ) then
         do
            local expList = _lune.nilacc( argList, 'get_expList', 'callmtd' )
            if expList ~= nil then
               if #expList > 0 then
                  exp = Nodes.LuneKindNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeInt}, expList[1] )
               end
               
            end
         end
         
      else
       
         exp = Nodes.ExpCallNode.create( self.nodeManager, firstToken.pos, retTypeInfoList, exp, errorFuncFlag, nilAccess, argList )
      end
      
   end
   
   return exp, self:getToken(  )
end

function TransUnit:analyzeExpCast( firstToken, opTxt, exp )

   local castTypeNode = self:analyzeRefType( Ast.AccessMode.Local, false )
   local castType = castTypeNode:get_expType()
   local expType = exp:get_expType()
   if opTxt == "@@@" or opTxt == "@@=" then
      if #castType:get_itemTypeInfoList() > 0 then
         self:addErrMess( castTypeNode:get_pos(), string.format( "not support cast for generics class yet -- %s", castType:getTxt(  )) )
      end
      
      do
         local _switchExp = castType:get_kind()
         if _switchExp == Ast.TypeInfoKind.IF or _switchExp == Ast.TypeInfoKind.Class or _switchExp == Ast.TypeInfoKind.Prim then
         else 
            
               self:addErrMess( castTypeNode:get_pos(), string.format( "not support cast -- %s", castType:getTxt(  )) )
         end
      end
      
      if opTxt == "@@=" then
         if castType:get_kind() ~= Ast.TypeInfoKind.IF and castType:get_kind() ~= Ast.TypeInfoKind.Class then
            self:addErrMess( castTypeNode:get_pos(), string.format( "'@@=' cast must be class or interface. -- %s", castType:getTxt(  )) )
         end
         
         if expType:get_srcTypeInfo() ~= Ast.builtinTypeStem and expType:get_kind() ~= Ast.TypeInfoKind.IF and expType:get_kind() ~= Ast.TypeInfoKind.Class then
            self:addErrMess( castTypeNode:get_pos(), string.format( "'@@=' cast must be class or interface. -- %s", castType:getTxt(  )) )
         end
         
         if not Ast.isStruct( castType ) then
            self:addErrMess( castTypeNode:get_pos(), string.format( "'@@=' cast type can't use class has method -- %s", castType:getTxt(  )) )
         end
         
      end
      
   else
    
      if castType ~= Ast.builtinTypeString and (castType:get_kind() == Ast.TypeInfoKind.IF or castType:get_kind() == Ast.TypeInfoKind.Class ) then
         self:addWarnMess( castTypeNode:get_pos(), string.format( "use '@@@' cast for class or interface. -- %s", castType:getTxt(  )) )
      end
      
   end
   
   if opTxt ~= "@@@" and expType:get_nilable() and not castType:get_nilable() then
      self:addErrMess( firstToken.pos, string.format( "can't cast from nilable to not nilable  -- %s->%s", expType:getTxt(  ), castType:getTxt(  )) )
   end
   
   if not Ast.TypeInfo.isMut( expType ) and Ast.TypeInfo.isMut( castType ) then
      castType = self:createModifier( castType, Ast.MutMode.IMut )
   end
   
   if castType:canEvalWith( expType, Ast.CanEvalType.SetOp, {} ) then
      self:addWarnMess( castTypeNode:get_pos(), string.format( "This cast isn't need. (%s <- %s)", castType:getTxt( true ), expType:getTxt( true )) )
   elseif not expType:canEvalWith( castType, Ast.CanEvalType.SetOp, {} ) then
      if not Ast.isNumberType( expType ) or not Ast.isNumberType( castType ) then
         self:addErrMess( castTypeNode:get_pos(), string.format( "This type can't cast. (%s <- %s)", castType:getTxt( true ), expType:getTxt( true )) )
      end
      
   end
   
   if opTxt == "@@@" then
      castType = castType:get_nilableTypeInfo()
   end
   
   return Nodes.ExpCastNode.create( self.nodeManager, firstToken.pos, {castType}, self.nodeManager:MultiTo1( exp ), castType, opTxt ~= "@@@" and Nodes.CastKind.Force or Nodes.CastKind.Normal )
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
            matchFlag = true
            exp, nextToken = self:analyzeExpCall( firstToken, exp, nextToken )
         end
         
      until not matchFlag
      do
         local _switchExp = nextToken.txt
         if _switchExp == "@@" or _switchExp == "@@@" or _switchExp == "@@=" then
            exp = self:analyzeExpCast( firstToken, nextToken.txt, exp )
            nextToken = self:getToken(  )
         end
      end
      
   end
   
   do
      local _switchExp = nextToken.txt
      if _switchExp == "." then
         return self:analyzeExpSymbol( firstToken, self:getToken(  ), ExpSymbolMode.Field, exp, skipFlag )
      elseif _switchExp == "$." then
         return self:analyzeExpSymbol( firstToken, self:getToken(  ), ExpSymbolMode.FieldNil, exp, skipFlag )
      elseif _switchExp == ".$" then
         return self:analyzeExpSymbol( firstToken, self:getToken(  ), ExpSymbolMode.Get, exp, skipFlag )
      elseif _switchExp == "$.$" then
         return self:analyzeExpSymbol( firstToken, self:getToken(  ), ExpSymbolMode.GetNil, exp, skipFlag )
      end
   end
   
   self:pushback(  )
   return exp
end

function TransUnit:analyzeAccessClassField( classTypeInfo, mode, token )

   do
      local _switchExp = classTypeInfo:get_kind(  )
      if _switchExp == Ast.TypeInfoKind.List then
         classTypeInfo = Ast.builtinTypeList
      elseif _switchExp == Ast.TypeInfoKind.Array then
         classTypeInfo = Ast.builtinTypeArray
      elseif _switchExp == Ast.TypeInfoKind.Set then
         classTypeInfo = Ast.builtinTypeSet
      end
   end
   
   local className = classTypeInfo:getTxt(  )
   local classScope = classTypeInfo:get_scope()
   if  nil == classScope then
      local _classScope = classScope
   
      self:error( string.format( "not found field: %s, %s", className, tostring( classTypeInfo)) )
   end
   
   local symbolInfo = nil
   local fieldTypeInfo = nil
   local getterFlag = false
   if mode == ExpSymbolMode.Get or mode == ExpSymbolMode.GetNil then
      local fieldSymbolInfo = classScope:getSymbolInfo( string.format( "get_%s", token.txt), self.scope, false )
      if fieldSymbolInfo ~= nil then
         if (fieldSymbolInfo:get_kind(  ) == Ast.SymbolKind.Mtd or fieldSymbolInfo:get_kind(  ) == Ast.SymbolKind.Fun ) then
            local retTypeList = fieldSymbolInfo:get_typeInfo():get_retTypeInfoList(  )
            symbolInfo = fieldSymbolInfo
            if #retTypeList > 0 then
               fieldTypeInfo = retTypeList[1]
               if fieldTypeInfo ~= nil then
                  do
                     local _exp = fieldTypeInfo:applyGeneric( classTypeInfo:createAlt2typeMap( false ), self.moduleType )
                     if _exp ~= nil then
                        fieldTypeInfo = _exp
                     end
                  end
                  
               end
               
            end
            
            getterFlag = true
         end
         
      end
      
   end
   
   if not symbolInfo then
      symbolInfo = classScope:getSymbolInfoField( token.txt, true, self.scope )
      if not symbolInfo then
         symbolInfo = classScope:getSymbolInfoIfField( token.txt, self.scope )
      end
      
      if symbolInfo ~= nil then
         fieldTypeInfo = symbolInfo:get_typeInfo()
      end
      
   end
   
   if not fieldTypeInfo then
      for name, val in pairs( classScope:get_symbol2SymbolInfoMap() ) do
         Util.log( string.format( "debug: %s, %s", name, tostring( val)) )
      end
      
      self:error( string.format( "not found field typeInfo: %s.%s", className, token.txt) )
   end
   
   local typeInfo = _lune.unwrapDefault( fieldTypeInfo, Ast.builtinTypeNone)
   if symbolInfo ~= nil then
      if self:inAnalyzingState( AnalyzingState.InitBlock ) or self:inAnalyzingState( AnalyzingState.ClassMethod ) then
         local errorMess = nil
         if self.protoFuncMap[symbolInfo:get_typeInfo()] then
            errorMess = string.format( "It can't call prototype function from static -- %s", symbolInfo:get_name())
         end
         
         if errorMess ~= nil then
            self:addErrMess( token.pos, errorMess )
         end
         
      elseif self:inAnalyzingState( AnalyzingState.Constructor ) then
         local errorMess = nil
         if self.protoFuncMap[symbolInfo:get_typeInfo()] then
            errorMess = "It can't call prototype function from '__init'"
         else
          
            if symbolInfo:get_typeInfo():get_kind() == Ast.TypeInfoKind.Method and symbolInfo:get_scope() == classScope then
               for name, val in pairs( classScope:get_symbol2SymbolInfoMap() ) do
                  if val:get_kind() == Ast.SymbolKind.Mbr and not val:get_staticFlag() then
                     if not val:get_hasValueFlag() and not val:get_typeInfo():get_nilable() then
                        errorMess = string.format( "Set member(%s) before to access the method-- %s", val:get_name(), symbolInfo:get_name())
                        break
                     end
                     
                  end
                  
               end
               
            end
            
         end
         
         if errorMess ~= nil then
            self:addErrMess( token.pos, errorMess )
         end
         
      end
      
   end
   
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
            if _switchExp == Ast.SymbolKind.Mtd or _switchExp == Ast.SymbolKind.Fun then
               writer:write( "displayTxt", string.format( "$%s", (typeInfo:get_rawTxt():gsub( "^get_", "" ) )) )
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
               local name = symbolInfo:get_name()
               do
                  local algeTypeInfo = _lune.__Cast( typeInfo, 3, Ast.AlgeTypeInfo )
                  if algeTypeInfo ~= nil then
                     do
                        local valInfo = algeTypeInfo:getValInfo( name )
                        if valInfo ~= nil then
                           if #valInfo:get_typeList() > 0 then
                              name = string.format( "%s(", name)
                              for index, itemType in pairs( valInfo:get_typeList() ) do
                                 if index > 1 then
                                    name = name .. ","
                                 end
                                 
                                 name = name .. itemType:get_display_stirng()
                              end
                              
                              name = name .. ")"
                           end
                           
                        end
                     end
                     
                  end
               end
               
               writer:write( "displayTxt", string.format( "%s: %s", name, typeInfo:get_display_stirng()) )
            elseif _switchExp == Ast.SymbolKind.Typ then
               writer:write( "displayTxt", string.format( "%s", (typeInfo:get_display_stirng():gsub( "@", "" ) )) )
            end
         end
         
      end
      
      writer:endElement(  )
   end
   
   return true
end

function TransUnit:dumpFieldComp( writer, isPrefixType, prefixTypeInfo, pattern, getterPattern )

   local typeInfo = prefixTypeInfo
   local scope = typeInfo:get_scope()
   if  nil == scope then
      local _scope = scope
   
      return 
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
      if symbol ~= "__init" and symbol ~= "__free" and symbol ~= "self" then
         if getterPattern ~= nil then
            if symbolInfo:get_kind() == Ast.SymbolKind.Mtd or symbolInfo:get_kind() == Ast.SymbolKind.Fun then
               local typeInfo = symbolInfo:get_typeInfo()
               local retList = typeInfo:get_retTypeInfoList()
               if #retList == 1 then
                  return self:dumpComp( writer, getterPattern, symbolInfo, true )
               end
               
            end
            
            return true
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

   if self.analyzeMode == AnalyzeMode.Complete and self.analyzePos.lineNo == token.pos.lineNo and self.analyzePos.column >= token.pos.column and self.analyzePos.column <= token.pos.column + #token.txt then
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

   if self.analyzeMode ~= AnalyzeMode.Complete then
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
      
      local isPrefixType = false
      do
         local _exp = prefixSymbolInfo
         if _exp ~= nil then
            isPrefixType = _exp:get_kind() == Ast.SymbolKind.Typ
         end
      end
      
      self:dumpFieldComp( jsonWriter, isPrefixType, prefixExp:get_expType(), prefix == "" and "" or "^" .. prefix, getterPattern )
   end
    )
end

function TransUnit:checkEnumComp( token, enumTypeInfo )

   if self.analyzeMode ~= AnalyzeMode.Complete then
      return 
   end
   
   self:checkComp( token, function ( jsonWriter, prefix )
   
      local scope = enumTypeInfo:get_scope()
      if  nil == scope then
         local _scope = scope
      
         return 
      end
      
      local pattern = prefix == "" and "" or "^" .. prefix
      scope:filterTypeInfoField( true, self.scope, function ( symbolInfo )
      
         if symbolInfo:get_kind() == Ast.SymbolKind.Mbr then
            return self:dumpComp( jsonWriter, pattern, symbolInfo, false )
         end
         
         return true
      end
       )
   end
    )
end

function TransUnit:checkAlgeComp( token, algeTypeInfo )

   if self.analyzeMode ~= AnalyzeMode.Complete then
      return 
   end
   
   self:checkComp( token, function ( jsonWriter, prefix )
   
      self:dumpFieldComp( jsonWriter, true, algeTypeInfo, prefix == "" and "" or "^" .. prefix, nil )
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
   if mode == ExpSymbolMode.FieldNil or mode == ExpSymbolMode.GetNil then
      accessNil = true
   end
   
   if self.macroMode == Nodes.MacroMode.Analyze then
      if accessNil then
         self.helperInfo.useNilAccess = true
      end
      
      return Nodes.RefFieldNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeSymbol}, token, nil, accessNil, prefixExp )
   end
   
   local typeInfo = Ast.builtinTypeStem_
   local prefixExpType = prefixExp:get_expType()
   self:checkFieldComp( mode == ExpSymbolMode.Get or mode == ExpSymbolMode.GetNil, token, prefixExp )
   if accessNil then
      if prefixExpType:get_nilable() then
         prefixExpType = prefixExpType:get_nonnilableType()
         if prefixExpType:get_srcTypeInfo():get_kind() == Ast.TypeInfoKind.Box then
            self:addErrMess( prefixExp:get_pos(), "Nilable can't support '$.' access yet" )
         end
         
      else
       
         accessNil = false
      end
      
   end
   
   if accessNil then
      self.helperInfo.useNilAccess = true
      do
         local _switchExp = prefixExpType:get_kind(  )
         if _switchExp == Ast.TypeInfoKind.Set or _switchExp == Ast.TypeInfoKind.Enum or _switchExp == Ast.TypeInfoKind.Alge then
            self:addErrMess( firstToken.pos, string.format( "%s does not support $.", prefixExpType:getTxt( false )) )
         end
      end
      
   end
   
   local prefixSymbolInfoList = prefixExp:getSymbolInfo(  )
   self:checkSymbolHavingValue( prefixExp:get_pos(), prefixSymbolInfoList )
   local getterTypeInfo = nil
   local symbolInfo = nil
   do
      local _switchExp = prefixExpType:get_kind()
      if _switchExp == Ast.TypeInfoKind.Class or _switchExp == Ast.TypeInfoKind.Module or _switchExp == Ast.TypeInfoKind.IF or _switchExp == Ast.TypeInfoKind.List or _switchExp == Ast.TypeInfoKind.Array or _switchExp == Ast.TypeInfoKind.Set or _switchExp == Ast.TypeInfoKind.Box or _switchExp == Ast.TypeInfoKind.Alternate then
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
         
      elseif _switchExp == Ast.TypeInfoKind.Enum or _switchExp == Ast.TypeInfoKind.Alge then
         local scope = _lune.unwrap( prefixExpType:get_scope())
         local fieldName = token.txt
         local symbolInfoList = prefixExp:getSymbolInfo(  )
         local isTypeSymbol = false
         if #symbolInfoList > 0 then
            if symbolInfoList[1]:get_kind() == Ast.SymbolKind.Typ then
               isTypeSymbol = true
            end
            
         end
         
         if mode == ExpSymbolMode.Get then
            local moduleType = prefixExpType:getModule(  )
            if not moduleType:equals( self.moduleType ) and not self.importModule2ModuleInfoCurrent[moduleType] then
               self:addErrMess( token.pos, string.format( "need to import module -- %s", prefixExpType:getModule(  ):getTxt(  )) )
            end
            
            fieldName = "get_" .. fieldName
            do
               local funcType = scope:getTypeInfoChild( fieldName )
               if funcType ~= nil then
                  if funcType:get_staticFlag() ~= isTypeSymbol then
                     self:addErrMess( prefixExp:get_pos(), string.format( "Can't access -- %s, %s", fieldName, tostring( isTypeSymbol)) )
                  end
                  
                  local retTypeList = funcType:get_retTypeInfoList()
                  if #retTypeList == 0 then
                     self:addErrMess( token.pos, string.format( "The func (%s) doesn't return value.", funcType:getTxt(  )) )
                  else
                   
                     typeInfo = retTypeList[1]
                  end
                  
               else
                  self:addErrMess( token.pos, string.format( "not found -- %s.", fieldName) )
                  typeInfo = Ast.builtinTypeNone
               end
            end
            
            getterTypeInfo = Ast.headTypeInfo
         else
          
            do
               local _exp = scope:getTypeInfoChild( fieldName )
               if _exp ~= nil then
                  typeInfo = _exp
                  if typeInfo:get_kind() == Ast.TypeInfoKind.Enum or typeInfo:get_kind() == Ast.TypeInfoKind.Alge then
                     if not isTypeSymbol then
                        self:addErrMess( token.pos, string.format( "can't access field -- %s", token.txt) )
                     end
                     
                  end
                  
               else
                  self:addErrMess( token.pos, string.format( "not found field -- %s", token.txt) )
                  typeInfo = Ast.builtinTypeInt
               end
            end
            
         end
         
      elseif _switchExp == Ast.TypeInfoKind.Map then
         local work = prefixExpType:get_itemTypeInfoList()[1]
         if not work:equals( Ast.builtinTypeString ) then
            self:addErrMess( token.pos, string.format( "map key type is not str. (%s)", work:getTxt(  )) )
         end
         
         typeInfo = prefixExpType:get_itemTypeInfoList()[2]
         if not typeInfo:get_nilable() then
            typeInfo = typeInfo:get_nilableTypeInfo()
         end
         
         return Nodes.ExpRefItemNode.create( self.nodeManager, token.pos, {typeInfo}, prefixExp, accessNil, token.txt, nil )
      else 
         
            if prefixExpType:equals( Ast.builtinTypeStem ) then
               return Nodes.ExpRefItemNode.create( self.nodeManager, token.pos, {Ast.builtinTypeStem_}, prefixExp, accessNil, token.txt, nil )
            else
             
               self:error( string.format( "illegal type -- %s, %s", prefixExpType:getTxt(  ), Ast.TypeInfoKind:_getTxt( prefixExpType:get_kind(  ))
               ) )
            end
            
      end
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
   
   if symbolInfo ~= nil then
      if #prefixSymbolInfoList == 1 then
         local prefixSymbolInfo = prefixSymbolInfoList[1]
         if prefixSymbolInfo:get_kind() == Ast.SymbolKind.Typ then
            if not symbolInfo:get_staticFlag() and symbolInfo:get_kind() ~= Ast.SymbolKind.Typ then
               self:addErrMess( token.pos, string.format( "Type can't access this symbol. -- %s", symbolInfo:get_name()) )
            end
            
         elseif symbolInfo:get_staticFlag() and symbolInfo:get_typeInfo():get_kind() ~= Ast.TypeInfoKind.Method then
            self:addErrMess( token.pos, string.format( "can't access this symbol. -- %s", token.txt) )
         end
         
      end
      
      
      if not Ast.TypeInfo.isMut( prefixExpType ) and not symbolInfo:get_staticFlag() and symbolInfo:get_kind() == Ast.SymbolKind.Mtd and symbolInfo:get_mutable() then
         self:addErrMess( token.pos, string.format( "can't access mutable method. -- %s", token.txt) )
      end
      
   end
   
   if accessNil then
      if not typeInfo:get_nilable() then
         typeInfo = typeInfo:get_nilableTypeInfo()
      end
      
      self.helperInfo.useNilAccess = true
   end
   
   local accessSymbolInfo = nil
   local symbolMutMode = typeInfo:get_mutMode()
   if symbolInfo ~= nil then
      accessSymbolInfo = Ast.AccessSymbolInfo.new(symbolInfo, prefixExpType, not accessNil)
      do
         local _switchExp = mode
         if _switchExp == ExpSymbolMode.Field or _switchExp == ExpSymbolMode.FieldNil then
            symbolMutMode = symbolInfo:get_mutMode()
         end
      end
      
   end
   
   if not Ast.TypeInfo.isMut( prefixExpType ) and symbolMutMode == Ast.MutMode.Mut then
      typeInfo = self:createModifier( typeInfo, Ast.MutMode.IMut )
   end
   
   if typeInfo:equals( builtinFunc.list_unpack ) or typeInfo:equals( builtinFunc.array_unpack ) then
      self.helperInfo.useUnpack = true
   end
   
   do
      local _exp = getterTypeInfo
      if _exp ~= nil then
         return Nodes.GetFieldNode.create( self.nodeManager, firstToken.pos, {typeInfo}, token, accessSymbolInfo, accessNil, prefixExp, _exp )
      else
         return Nodes.RefFieldNode.create( self.nodeManager, firstToken.pos, {typeInfo}, token, accessSymbolInfo, accessNil, prefixExp )
      end
   end
   
end

function TransUnit:analyzeNewAlge( firstToken, algeTypeInfo, prefix )

   local symbolToken = self:getSymbolToken( SymbolMode.MustNot_ )
   self:checkAlgeComp( symbolToken, algeTypeInfo )
   do
      local valInfo = algeTypeInfo:getValInfo( symbolToken.txt )
      if valInfo ~= nil then
         local argList = {}
         local argListNode
         
         if #valInfo:get_typeList() > 0 then
            self:checkNextToken( "(" )
            argListNode = self:analyzeExpList( false, false, nil, valInfo:get_typeList(), nil )
            argList = (_lune.unwrap( argListNode) ):get_expList()
            self:checkNextToken( ")" )
         else
          
            argListNode = nil
         end
         
         do
            local alt2typeMap, newExpNodeList = self:checkMatchType( "call", symbolToken.pos, valInfo:get_typeList(), argListNode, false, true, nil )
            if alt2typeMap ~= nil and newExpNodeList ~= nil then
               argList = newExpNodeList:get_expList()
            end
         end
         
         if algeTypeInfo:get_externalFlag() and not self.importModule2ModuleInfoCurrent[algeTypeInfo:getModule(  ):get_srcTypeInfo()] then
            local fullname = algeTypeInfo:getFullName( self.importModule2ModuleInfo, true )
            self:addErrMess( firstToken.pos, string.format( "This module not import -- %s", fullname) )
         end
         
         return Nodes.NewAlgeValNode.create( self.nodeManager, firstToken.pos, {algeTypeInfo}, symbolToken, prefix, algeTypeInfo, valInfo, argList )
      else
         self:addErrMess( symbolToken.pos, string.format( "not found Alge -- %s", symbolToken.txt) )
         return Nodes.NewAlgeValNode.create( self.nodeManager, firstToken.pos, {algeTypeInfo}, symbolToken, prefix, algeTypeInfo, Ast.AlgeValInfo.new("", {}), {} )
      end
   end
   
end

function TransUnit:analyzeExpSymbol( firstToken, token, mode, prefixExp, skipFlag )

   local exp
   
   if mode == ExpSymbolMode.Field or mode == ExpSymbolMode.Get or mode == ExpSymbolMode.FieldNil or mode == ExpSymbolMode.GetNil then
      if prefixExp ~= nil then
         exp = self:analyzeExpField( firstToken, token, mode, prefixExp )
         local expType = exp:get_expType()
         if prefixExp:get_expType():isModule(  ) then
            do
               local algeType = _lune.__Cast( expType, 3, Ast.AlgeTypeInfo )
               if algeType ~= nil then
                  local nextToken = self:getToken(  )
                  if nextToken.txt == "." then
                     return self:analyzeNewAlge( firstToken, algeType, exp )
                  end
                  
                  self:pushback(  )
               end
            end
            
         end
         
      else
         Util.err( "prefixExp is nil" )
      end
      
   elseif mode == ExpSymbolMode.Symbol then
      if self.macroMode == Nodes.MacroMode.Analyze then
         exp = Nodes.LiteralSymbolNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeSymbol}, token )
      else
       
         self:checkSymbolComp( token )
         local symbolInfo = self.scope:getSymbolTypeInfo( token.txt, self.scope, self.moduleScope )
         if  nil == symbolInfo then
            local _symbolInfo = symbolInfo
         
            local work = self.scope
            while true do
               print( work, self.globalScope, Ast.rootScope )
               if work == work:get_parent() then
                  break
               end
               
               work = work:get_parent()
            end
            
            self.scope:filterSymbolTypeInfo( self.scope, self.moduleScope, function ( workSymbolInfo )
            
               print( "sym", workSymbolInfo:get_name() )
               return true
            end
             )
            self:error( "not found type -- " .. token.txt )
         end
         
         local typeInfo = symbolInfo:get_typeInfo()
         do
            local _switchExp = symbolInfo:get_kind()
            if _switchExp == Ast.SymbolKind.Typ then
               do
                  local algeType = _lune.__Cast( typeInfo, 3, Ast.AlgeTypeInfo )
                  if algeType ~= nil then
                     local nextToken = self:getToken(  )
                     if nextToken.txt == "." then
                        return self:analyzeNewAlge( firstToken, algeType, nil )
                     end
                     
                     self:pushback(  )
                  end
               end
               
            elseif _switchExp == Ast.SymbolKind.Var then
               if not symbolInfo:get_hasValueFlag() then
                  local nsTypeInfo = self:getCurrentNamespaceTypeInfo(  )
                  if not symbolInfo:get_scope():isInnerOf( _lune.unwrap( nsTypeInfo:get_scope()) ) then
                     self:addErrMess( firstToken.pos, string.format( "This can't access variable have no value -- %s", symbolInfo:get_name()) )
                  end
                  
               end
               
            end
         end
         
         if typeInfo:equals( Ast.builtinTypeSymbol ) then
            skipFlag = true
         end
         
         if typeInfo:equals( builtinFunc.lune__load ) then
            self.helperInfo.useLoad = true
         end
         
         if token.txt == "__func__" then
            local funcTypeInfo = self:getCurrentNamespaceTypeInfo(  )
            self.has__func__Symbol[funcTypeInfo]= true
         end
         
         exp = Nodes.ExpRefNode.create( self.nodeManager, firstToken.pos, {typeInfo}, token, Ast.AccessSymbolInfo.new(symbolInfo, nil, true) )
      end
      
   elseif mode == ExpSymbolMode.Fn then
      exp = self:analyzeDeclFunc( DeclFuncMode.Func, false, false, Ast.AccessMode.Local, false, nil, token, nil )
   else
    
      self:error( string.format( "illegal mode -- %s", tostring( mode)) )
   end
   
   return self:analyzeExpCont( firstToken, exp, skipFlag )
end

function TransUnit:analyzeExpOpSet( exp, opeToken, expList )

   if not exp:canBeLeft(  ) then
      self:addErrMess( exp:get_pos(), string.format( "this node can not be l-value. -- %s", Nodes.getNodeKindName( exp:get_kind() )) )
   end
   
   local alt2typeMap, newExpListNode, expTypeList = self:checkMatchType( "= operator", opeToken.pos, exp:get_expTypeList(), expList, true, false, nil )
   for index, symbolInfo in pairs( exp:getSymbolInfo(  ) ) do
      if not symbolInfo:get_mutable() and symbolInfo:get_hasValueFlag() then
         if self.validMutControl then
            self:addErrMess( opeToken.pos, string.format( "this is not mutable variable. -- %s", symbolInfo:get_name()) )
         end
         
      end
      
      if index <= #expTypeList and not symbolInfo:get_hasValueFlag() and symbolInfo:get_kind() == Ast.SymbolKind.Var then
         if symbolInfo:get_typeInfo() == Ast.builtinTypeEmpty then
            local expType = expTypeList[index]
            if expType:get_kind() == Ast.TypeInfoKind.DDD then
               if #expType:get_itemTypeInfoList() > 0 then
                  expType = expType:get_itemTypeInfoList()[1]:get_nilableTypeInfo()
               end
               
            end
            
            symbolInfo:set_typeInfo( expType )
         end
         
         if not self.tentativeSymbol:regist( symbolInfo ) then
            self:addErrMess( opeToken.pos, string.format( "can't access in this scope. -- %s", symbolInfo:get_name()) )
         end
         
      end
      
      symbolInfo:set_hasValueFlag( true )
   end
   
   return newExpListNode
end

function TransUnit:analyzeExpOp2( firstToken, exp, prevOpLevel )

   while true do
      local nextToken = self:getToken(  )
      local opTxt = nextToken.txt
      if nextToken.txt == "@@" or nextToken.txt == "@@@" or nextToken.txt == "@@=" then
         exp = self:analyzeExpCast( firstToken, opTxt, exp )
      elseif nextToken.kind == Parser.TokenKind.Ope then
         if Parser.isOp2( opTxt ) then
            if opTxt ~= "=" and not exp:canBeRight(  ) then
               self:addErrMess( exp:get_pos(), string.format( "This can't evaluate for '%s' -- %s", opTxt, Nodes.getNodeKindName( exp:get_kind() )) )
            end
            
            local opLevel = op2levelMap[opTxt]
            if  nil == opLevel then
               local _opLevel = opLevel
            
               self:error( string.format( "unknown op -- %s %s", opTxt, tostring( prevOpLevel)) )
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
            
            local expectTypeList = {}
            for __index, exp1Type in pairs( exp:get_expTypeList() ) do
               local prefixExpType = exp1Type
               if prefixExpType:get_nilable() then
                  prefixExpType = prefixExpType:get_nonnilableType()
               end
               
               local expectType = Ast.builtinTypeNone
               do
                  local _exp = _lune.__Cast( prefixExpType:get_srcTypeInfo(), 3, Ast.EnumTypeInfo )
                  if _exp ~= nil then
                     expectType = _exp
                  end
               end
               
               do
                  local _exp = _lune.__Cast( prefixExpType:get_srcTypeInfo(), 3, Ast.AlgeTypeInfo )
                  if _exp ~= nil then
                     expectType = _exp
                  end
               end
               
               table.insert( expectTypeList, expectType )
            end
            
            local exp2
            
            if opTxt == "=" then
               local expListNode = self:analyzeExpList( false, false, nil, expectTypeList )
               exp2 = expListNode
            else
             
               exp2 = self:analyzeExp( false, false, opLevel, expectTypeList[1] )
               if not exp2:canBeRight(  ) then
                  self:addErrMess( exp2:get_pos(), string.format( "This can't evaluate for '%s' -- %s", opTxt, Nodes.getNodeKindName( exp2:get_kind() )) )
               end
               
            end
            
            local info = {["op"] = nextToken, ["exp1"] = exp, ["exp2"] = exp2}
            local retType = Ast.builtinTypeNone
            if not exp2:canBeRight(  ) then
               self:addErrMess( exp2:get_pos(), string.format( "this node can not be r-value. -- %s", Nodes.getNodeKindName( exp2:get_kind() )) )
            end
            
            local exp1Type = exp:get_expType()
            local exp2Type = exp2:get_expType()
            if opTxt ~= "=" then
               if exp1Type:get_kind() == Ast.TypeInfoKind.DDD then
                  self:addErrMess( exp:get_pos(), string.format( "... can't evaluate for %s", opTxt) )
               elseif exp2Type:get_kind() == Ast.TypeInfoKind.DDD then
                  self:addErrMess( exp2:get_pos(), string.format( "... can't evaluate for %s", opTxt) )
               end
               
            end
            
            do
               local _switchExp = opTxt
               if _switchExp == "or" then
                  if exp1Type:equals( exp2Type ) then
                     retType = exp1Type
                  elseif exp1Type:canEvalWith( exp2Type, Ast.CanEvalType.SetOp, {} ) then
                     retType = exp1Type
                  elseif exp2Type:canEvalWith( exp1Type, Ast.CanEvalType.SetOp, {} ) then
                     retType = exp2Type
                  elseif exp2Type:equals( Ast.builtinTypeNil ) then
                     retType = exp1Type
                  elseif exp1Type:equals( Ast.builtinTypeNil ) then
                     retType = exp2Type
                  else
                   
                     if exp1Type:get_nilable() or exp2Type:get_nilable() then
                        retType = Ast.builtinTypeStem_
                     else
                      
                        retType = Ast.builtinTypeStem
                     end
                     
                  end
                  
               elseif _switchExp == "and" then
                  local workToken = self:getToken(  )
                  self:pushback(  )
                  if not exp1Type:equals( Ast.builtinTypeBool ) and not exp1Type:equals( Ast.builtinTypeStem ) and not exp1Type:get_nilable() then
                     self:addWarnMess( exp:get_pos(), "this value never be 'false'" )
                  elseif exp2:get_kind() == Nodes.NodeKind.get_LiteralBool() then
                     do
                        local literal = exp2:getLiteral(  )
                        if literal ~= nil then
                           if not Nodes.getLiteralObj( literal ) then
                              self:addErrMess( exp2:get_pos(), "this value never be 'true'" )
                           end
                           
                        end
                     end
                     
                  end
                  
                  if workToken.txt == "or" then
                     retType = exp2Type
                  else
                   
                     if exp1Type:get_nilable() then
                        if exp2Type:get_nilable() then
                           retType = exp2Type
                        else
                         
                           retType = exp2Type:get_nilableTypeInfo()
                        end
                        
                     elseif exp1Type:equals( Ast.builtinTypeBool ) or exp2Type:equals( Ast.builtinTypeBool ) then
                        if exp1Type:canEvalWith( exp2Type, Ast.CanEvalType.SetOp, {} ) then
                           retType = exp1Type
                        elseif exp2Type:canEvalWith( exp1Type, Ast.CanEvalType.SetOp, {} ) then
                           retType = exp2Type
                        else
                         
                           if exp2Type:get_nilable() then
                              retType = Ast.builtinTypeStem_
                           else
                            
                              retType = Ast.builtinTypeStem
                           end
                           
                        end
                        
                     else
                      
                        retType = exp2Type
                     end
                     
                  end
                  
               elseif _switchExp == "<" or _switchExp == ">" or _switchExp == "<=" or _switchExp == ">=" then
                  if Ast.builtinTypeString:canEvalWith( exp1Type, Ast.CanEvalType.SetOp, {} ) and Ast.builtinTypeString:canEvalWith( exp2Type, Ast.CanEvalType.SetOp, {} ) or (Ast.builtinTypeInt:canEvalWith( exp1Type, Ast.CanEvalType.Comp, {} ) or Ast.builtinTypeReal:canEvalWith( exp1Type, Ast.CanEvalType.Comp, {} ) ) and (Ast.builtinTypeInt:canEvalWith( exp2Type, Ast.CanEvalType.Comp, {} ) or Ast.builtinTypeReal:canEvalWith( exp2Type, Ast.CanEvalType.Comp, {} ) ) then
                     
                  else
                   
                     self:addErrMess( nextToken.pos, string.format( "no numeric type '%s' or '%s'", exp1Type:getTxt( true ), exp2Type:getTxt( true )) )
                  end
                  
                  retType = Ast.builtinTypeBool
               elseif _switchExp == "~=" or _switchExp == "==" then
                  if (not exp1Type:canEvalWith( exp2Type, Ast.CanEvalType.SetOp, {} ) and not exp2Type:canEvalWith( exp1Type, Ast.CanEvalType.SetOp, {} ) ) then
                     self:addErrMess( nextToken.pos, string.format( "not compatible type '%s' or '%s'", exp1Type:getTxt( true ), exp2Type:getTxt( true )) )
                  end
                  
                  do
                     local _exp = _lune.__Cast( exp, 3, Nodes.NewAlgeValNode )
                     if _exp ~= nil then
                        if #_exp:get_paramList() > 0 then
                           self:addErrMess( exp:get_pos(), "can't compare alge." )
                        end
                        
                     end
                  end
                  
                  do
                     local _exp = _lune.__Cast( exp2, 3, Nodes.NewAlgeValNode )
                     if _exp ~= nil then
                        if #_exp:get_paramList() > 0 then
                           self:addErrMess( exp2:get_pos(), "can't compare alge." )
                        end
                        
                     end
                  end
                  
                  if exp1Type:equals( Ast.builtinTypeBool ) and exp2Type:equals( Ast.builtinTypeBool ) and (exp:get_kind() == Nodes.NodeKind.get_LiteralBool() or exp2:get_kind() == Nodes.NodeKind.get_LiteralBool() ) then
                     self:addWarnMess( exp:get_pos(), "this operation is deprecated." )
                  end
                  
                  retType = Ast.builtinTypeBool
               elseif _switchExp == "^" or _switchExp == "|" or _switchExp == "~" or _switchExp == "&" or _switchExp == "|<<" or _switchExp == "|>>" then
                  if self.targetLuaVer:get_hasBitOp() == LuaVer.BitOp.Cant then
                     self:addErrMess( nextToken.pos, "this lua version can't use bit operand." )
                  end
                  
                  if not Ast.builtinTypeInt:canEvalWith( exp1Type, Ast.CanEvalType.Logical, {} ) or not Ast.builtinTypeInt:canEvalWith( exp2Type, Ast.CanEvalType.Logical, {} ) then
                     self:addErrMess( nextToken.pos, string.format( "no int type '%s' or '%s'", exp1Type:getTxt(  ), exp2Type:getTxt(  )) )
                  end
                  
                  retType = Ast.builtinTypeInt
               elseif _switchExp == ".." then
                  if not exp1Type:equals( Ast.builtinTypeString ) or not exp1Type:equals( Ast.builtinTypeString ) then
                     self:addErrMess( nextToken.pos, string.format( "no string type '%s' or '%s'", exp1Type:getTxt(  ), exp2Type:getTxt(  )) )
                  end
                  
                  retType = Ast.builtinTypeString
               elseif _switchExp == "+" or _switchExp == "-" or _switchExp == "*" or _switchExp == "/" or _switchExp == "%" then
                  if (not Ast.builtinTypeInt:canEvalWith( exp1Type, Ast.CanEvalType.Math, {} ) and not Ast.builtinTypeReal:canEvalWith( exp1Type, Ast.CanEvalType.Math, {} ) ) or (not Ast.builtinTypeInt:canEvalWith( exp2Type, Ast.CanEvalType.Math, {} ) and not Ast.builtinTypeReal:canEvalWith( exp2Type, Ast.CanEvalType.Math, {} ) ) then
                     self:addErrMess( nextToken.pos, string.format( "no numeric type '%s' or '%s'", exp1Type:getTxt(  ), exp2Type:getTxt(  )) )
                  end
                  
                  if exp1Type:equals( Ast.builtinTypeReal ) or exp2Type:equals( Ast.builtinTypeReal ) then
                     retType = Ast.builtinTypeReal
                  else
                   
                     retType = Ast.builtinTypeInt
                  end
                  
               elseif _switchExp == "=" then
                  do
                     local _exp = self:analyzeExpOpSet( exp, nextToken, _lune.unwrap( _lune.__Cast( exp2, 3, Nodes.ExpListNode )) )
                     if _exp ~= nil then
                        exp2 = _exp
                     end
                  end
                  
               else 
                  
                     self:error( "unknown op " .. opTxt )
               end
            end
            
            exp = Nodes.ExpOp2Node.create( self.nodeManager, firstToken.pos, {retType}, nextToken, self.nodeManager:MultiTo1( exp ), self.nodeManager:MultiTo1( exp2 ) )
         else
          
            self:error( "illegal op" )
         end
         
      else
       
         self:pushback(  )
         return exp
      end
      
   end
   
end

function TransUnit:analyzeExpMacroStat( firstToken )

   local expStrList = {}
   self:checkNextToken( "{" )
   local braceCount = 0
   local prevToken = firstToken
   while true do
      local token = self:getToken(  )
      if token.txt == ",," or token.txt == ",,," or token.txt == ",,,," then
         local exp = self:analyzeExp( false, true, _lune.unwrap( op1levelMap[token.txt]) )
         local nextToken = self:getToken(  )
         if nextToken.txt ~= "~~" then
            self:pushback(  )
         end
         
         local format = token.txt == ",,," and "' %s '" or '"\'%s\'"'
         if token.txt == ",," then
            do
               local refNode = _lune.__Cast( exp, 3, Nodes.ExpRefNode )
               if refNode ~= nil then
                  local refToken = refNode:get_token(  )
                  local macroInfo = self.symbol2ValueMapForMacro[refToken.txt]
                  if macroInfo ~= nil then
                     local valType = macroInfo.typeInfo
                     if valType:equals( Ast.builtinTypeSymbol ) or valType:equals( Ast.builtinTypeStat ) then
                        format = "' %s '"
                     elseif valType:get_kind() == Ast.TypeInfoKind.List and valType:get_itemTypeInfoList()[1]:equals( Ast.builtinTypeStat ) then
                        format = "' %s '"
                        exp = Nodes.ExpMacroStatListNode.create( self.nodeManager, token.pos, {Ast.builtinTypeString}, exp )
                     elseif Ast.builtinTypeString:equals( valType ) then
                     else
                      
                        self:addErrMess( refToken.pos, string.format( "not support ,, -- %s", valType:getTxt(  )) )
                     end
                     
                  else
                     if exp:get_expType():equals( Ast.builtinTypeInt ) or exp:get_expType():equals( Ast.builtinTypeReal ) then
                        format = "'%s' "
                     elseif exp:get_expType():equals( Ast.builtinTypeStat ) then
                        format = "' %s '"
                     end
                     
                  end
                  
               end
            end
            
         end
         
         local newToken = Parser.Token.new(Parser.TokenKind.Str, format, token.pos, token.consecutive)
         local literalStr = Nodes.LiteralStringNode.create( self.nodeManager, token.pos, {Ast.builtinTypeString}, newToken, {exp} )
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
         
         local format = "' %s'"
         local consecutive
         
         if prevToken == firstToken or token.consecutive then
            format = "'%s'"
            consecutive = true
         else
          
            consecutive = false
         end
         
         local newToken = Parser.Token.new(token.kind, string.format( format, token.txt ), token.pos, consecutive)
         local literalStr = Nodes.LiteralStringNode.create( self.nodeManager, token.pos, {Ast.builtinTypeString}, newToken, {} )
         table.insert( expStrList, literalStr )
      end
      
      prevToken = token
   end
   
   return Nodes.ExpMacroStatNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeStat}, expStrList )
end

function TransUnit:analyzeSuper( firstToken )

   self:checkNextToken( "(" )
   local nextToken = self:getToken(  )
   local expList = nil
   if nextToken.txt ~= ")" then
      self:pushback(  )
      expList = self:analyzeExpList( false, false )
      self:checkNextToken( ")" )
   end
   
   self:checkNextToken( ";" )
   local classType = self:getCurrentClass(  )
   local currentFunc = self:getCurrentNamespaceTypeInfo(  )
   if currentFunc:get_kind() == Ast.TypeInfoKind.Method then
      local superType = classType:get_baseTypeInfo(  )
      if superType:equals( Ast.headTypeInfo ) then
         self:addErrMess( firstToken.pos, "This class doesn't have super-class." )
      else
       
         if currentFunc:get_rawTxt() == "__init" then
            local superScope = superType:get_scope()
            if  nil == superScope then
               local _superScope = superScope
            
               self:error( "not found super scope" )
            end
            
            local superCtorType = superScope:getTypeInfoChild( "__init" )
            if  nil == superCtorType then
               local _superCtorType = superCtorType
            
               self:error( "not found super '__init'" )
            end
            
            self:checkMatchValType( firstToken.pos, superCtorType, expList, {}, classType )
            return Nodes.ExpCallSuperNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeNone}, superType, superCtorType, expList )
         else
          
            do
               local superFunc = (_lune.unwrap( superType:get_scope()) ):getTypeInfoField( currentFunc:get_rawTxt(), true, self.scope )
               if superFunc ~= nil then
                  if superFunc:get_abstractFlag() then
                     self:addErrMess( firstToken.pos, "super is abstract." )
                  end
                  
                  self:checkMatchValType( firstToken.pos, superFunc, expList, {}, classType )
                  return Nodes.ExpCallSuperNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeNone}, superType, superFunc, expList )
               end
            end
            
            self:addErrMess( firstToken.pos, "this is not override method." )
            return self:createNoneNode( firstToken.pos )
         end
         
      end
      
   end
   
   self:addErrMess( firstToken.pos, "super can't call here." )
   return self:createNoneNode( firstToken.pos )
end

function TransUnit:analyzeUnwrap( firstToken )

   local nextToken, continueFlag = self:getContinueToken(  )
   if not continueFlag or nextToken.txt ~= "!" then
      self:pushback(  )
      self:pushbackToken( firstToken )
      local exp = self:analyzeExp( false, false )
      self:checkNextToken( ";" )
      if not exp:get_expType():get_nilable() then
         self:addErrMess( exp:get_pos(), "this value is not nilable." )
      end
      
      return Nodes.StmtExpNode.create( self.nodeManager, nextToken.pos, {Ast.builtinTypeNone}, exp )
   end
   
   self:pushback(  )
   return self:analyzeDeclVar( Nodes.DeclVarMode.Unwrap, Ast.AccessMode.Local, firstToken )
end

function TransUnit:analyzeExpUnwrap( firstToken )

   local expNode = self:analyzeExp( false, true )
   local nextToken = self:getToken(  )
   local insNode = nil
   if nextToken.txt == "default" then
      insNode = self:analyzeExp( false, false )
   else
    
      self:pushback(  )
   end
   
   local unwrapType = Ast.builtinTypeStem_
   local expType = expNode:get_expType()
   if not expType:get_nilable() then
      unwrapType = expType
      self:addErrMess( expNode:get_pos(), string.format( "this exp is not nilable -- %s", expType:getTxt(  )) )
   elseif expType:get_kind() == Ast.TypeInfoKind.DDD then
      if #expType:get_itemTypeInfoList() > 0 then
         unwrapType = expType:get_itemTypeInfoList()[1]
      else
       
         unwrapType = Ast.builtinTypeStem
      end
      
   else
    
      unwrapType = expType:get_nonnilableType()
   end
   
   if insNode ~= nil then
      local insType = insNode:get_expType()
      if insType:get_nilable() then
         self:addErrMess( insNode:get_pos(), string.format( "default can't use nilable -- %s", insType:getTxt(  )) )
      end
      
      local alt2type = Ast.CanEvalCtrlTypeInfo.createDefaultAlt2typeMap( false )
      if not unwrapType:canEvalWith( insType, Ast.CanEvalType.SetOp, alt2type ) then
         if not insType:canEvalWith( unwrapType, Ast.CanEvalType.SetOp, alt2type ) then
            unwrapType = Ast.builtinTypeStem
         else
          
            unwrapType = insType
         end
         
      end
      
   end
   
   self.helperInfo.useUnwrapExp = true
   return Nodes.ExpUnwrapNode.create( self.nodeManager, firstToken.pos, {unwrapType}, expNode, insNode )
end

function TransUnit:analyzeExp( allowNoneType, skipOp2Flag, prevOpLevel, expectType )

   local firstToken = self:getToken(  )
   local function processsExpectExp( token, orgExpectType )
   
      do
         local enumTyepInfo = _lune.__Cast( orgExpectType:get_srcTypeInfo(), 3, Ast.EnumTypeInfo )
         if enumTyepInfo ~= nil then
            local nextToken = self:getToken(  )
            self:checkEnumComp( nextToken, enumTyepInfo )
            do
               local valInfo = enumTyepInfo:getEnumValInfo( nextToken.txt )
               if valInfo ~= nil then
                  if orgExpectType:get_externalFlag() and not self.importModule2ModuleInfoCurrent[orgExpectType:getModule(  ):get_srcTypeInfo()] then
                     local fullname = orgExpectType:getFullName( self.importModule2ModuleInfo, true )
                     self:addErrMess( token.pos, string.format( "This module not import -- %s", fullname) )
                  end
                  
                  local exp = Nodes.ExpOmitEnumNode.create( self.nodeManager, token.pos, {enumTyepInfo}, nextToken, valInfo, enumTyepInfo )
                  return self:analyzeExpCont( firstToken, exp, false )
               end
            end
            
            self:error( string.format( "illegal enum val -- %s.%s", orgExpectType:getTxt(  ), nextToken.txt) )
         end
      end
      
      do
         local algeTyepInfo = _lune.__Cast( orgExpectType:get_srcTypeInfo(), 3, Ast.AlgeTypeInfo )
         if algeTyepInfo ~= nil then
            return self:analyzeNewAlge( firstToken, algeTyepInfo, nil )
         end
      end
      
      self:error( string.format( "illegal type for '.' -- %s", orgExpectType:getTxt(  )) )
   end
   
   local function processsNewExp( token )
   
      local exp = self:analyzeRefType( Ast.AccessMode.Local, false )
      local classTypeInfo = exp:get_expType()
      do
         local _switchExp = classTypeInfo:get_kind()
         if _switchExp == Ast.TypeInfoKind.Class or _switchExp == Ast.TypeInfoKind.IF then
            if classTypeInfo:equals( Ast.builtinTypeString ) then
               self:error( string.format( "'new' can't use this type -- %s", classTypeInfo:getTxt(  )) )
            end
            
         else 
            
               self:error( string.format( "'new' can't use this type -- %s", classTypeInfo:getTxt(  )) )
         end
      end
      
      if classTypeInfo:get_externalFlag() then
         do
            local _switchExp = classTypeInfo:get_accessMode()
            if _switchExp == Ast.AccessMode.Pri or _switchExp == Ast.AccessMode.Local then
               self:addErrMess( token.pos, string.format( "Can't access -- %s", Ast.AccessMode:_getTxt( classTypeInfo:get_accessMode())
               ) )
            end
         end
         
      end
      
      if classTypeInfo:get_abstractFlag() then
         self:addErrMess( token.pos, "abstract class can't new" )
      end
      
      local classScope = classTypeInfo:get_scope(  )
      local initTypeInfo = (_lune.unwrap( classScope) ):getTypeInfoChild( "__init" )
      if  nil == initTypeInfo then
         local _initTypeInfo = initTypeInfo
      
         self:error( "not found __init" )
      end
      
      self:checkNextToken( "(" )
      local nextToken = self:getToken(  )
      local argList = nil
      if nextToken.txt ~= ")" then
         self:pushback(  )
         argList = self:analyzeExpList( false, false, nil, initTypeInfo:get_argTypeInfoList() )
         self:checkNextToken( ")" )
      end
      
      if initTypeInfo:get_accessMode() == Ast.AccessMode.Pub or (initTypeInfo:get_accessMode() == Ast.AccessMode.Pro and self.scope:getClassTypeInfo(  ):isInheritFrom( classTypeInfo, nil ) ) or (self.scope:getClassTypeInfo(  ) == classTypeInfo ) then
      else
       
         self:addErrMess( token.pos, string.format( "can't access to __init of %s", classTypeInfo:getTxt(  )) )
      end
      
      local alt2type, newArgList = self:checkMatchValType( exp:get_pos(), initTypeInfo, argList, classTypeInfo:get_itemTypeInfoList(), classTypeInfo )
      if #classTypeInfo:get_itemTypeInfoList() > 0 then
         if classTypeInfo:get_itemTypeInfoList()[1]:get_kind() == Ast.TypeInfoKind.Alternate then
            local genTypeList = {}
            local detect = true
            for __index, altType in pairs( classTypeInfo:get_itemTypeInfoList() ) do
               do
                  local _exp = alt2type[altType]
                  if _exp ~= nil then
                     table.insert( genTypeList, _exp )
                  else
                     self:addErrMess( token.pos, string.format( "Can't new generic class. -- %s", classTypeInfo:getTxt(  )) )
                     detect = false
                     break
                  end
               end
               
            end
            
            if detect then
               classTypeInfo = Ast.NormalTypeInfo.createGeneric( classTypeInfo, genTypeList, self.moduleType )
            end
            
         end
         
      end
      
      exp = Nodes.ExpNewNode.create( self.nodeManager, firstToken.pos, {classTypeInfo}, exp, newArgList )
      exp = self:analyzeExpCont( firstToken, exp, false )
      return exp
   end
   
   local function processOp1( token )
   
      if token.txt == "`" then
         return self:analyzeExpMacroStat( token ), false
      end
      
      local exp = self:analyzeExp( false, true, _lune.unwrap( op1levelMap[token.txt]) )
      local typeInfo = Ast.builtinTypeNone
      local macroExpFlag = false
      local expType = exp:get_expType()
      if expType:get_kind() == Ast.TypeInfoKind.DDD then
         self:addErrMess( exp:get_pos(), string.format( "... can't evaluate for '%s'.", token.txt) )
      end
      
      do
         local _switchExp = (token.txt )
         if _switchExp == "-" then
            if not expType:equals( Ast.builtinTypeInt ) and not expType:equals( Ast.builtinTypeReal ) then
               self:addErrMess( token.pos, string.format( 'unmatch type for "-" -- %s', expType:getTxt(  )) )
            end
            
            typeInfo = expType
         elseif _switchExp == "#" then
            if expType:get_kind() ~= Ast.TypeInfoKind.List and expType:get_kind() ~= Ast.TypeInfoKind.Array and not Ast.builtinTypeString:canEvalWith( expType, Ast.CanEvalType.SetOp, {} ) then
               self:addErrMess( token.pos, string.format( 'unmatch type for "#" -- %s', expType:getTxt(  )) )
            end
            
            typeInfo = Ast.builtinTypeInt
         elseif _switchExp == "not" then
            typeInfo = Ast.builtinTypeBool
            if not expType:get_nilable() and not expType:equals( Ast.builtinTypeBool ) and not expType:equals( Ast.builtinTypeStem ) and expType:get_kind() ~= Ast.TypeInfoKind.DDD then
               self:addErrMess( token.pos, "this 'not' operand never be false" )
            end
            
         elseif _switchExp == ",," then
            macroExpFlag = true
         elseif _switchExp == ",,," then
            macroExpFlag = true
            if not expType:equals( Ast.builtinTypeString ) then
               self:error( "unmatch ,,, type, need string type" )
            end
            
            typeInfo = Ast.builtinTypeSymbol
         elseif _switchExp == ",,,," then
            macroExpFlag = true
            if not expType:equals( Ast.builtinTypeSymbol ) then
               self:error( "unmatch ,,, type, need symbol type" )
            end
            
            typeInfo = Ast.builtinTypeString
         elseif _switchExp == "`" then
            typeInfo = Ast.builtinTypeNone
         elseif _switchExp == "~" then
            if not expType:equals( Ast.builtinTypeInt ) then
               self:addErrMess( token.pos, string.format( 'unmatch type for "~" -- %s', expType:getTxt(  )) )
            end
            
            typeInfo = Ast.builtinTypeInt
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
      
      exp = Nodes.ExpOp1Node.create( self.nodeManager, firstToken.pos, {typeInfo}, token, self.macroMode, self.nodeManager:MultiTo1( exp ) )
      return self:analyzeExpOp2( firstToken, exp, prevOpLevel ), true
   end
   
   local token = firstToken
   local exp = self:createNoneNode( firstToken.pos )
   if token.txt == "##" then
      if allowNoneType then
         self:addErrMess( token.pos, "illeal syntax -- ##" )
      end
      
      return Nodes.AbbrNode.create( self.nodeManager, token.pos, {Ast.builtinTypeAbbr} )
   end
   
   if token.kind == Parser.TokenKind.Dlmt then
      if token.txt == "." then
         if expectType ~= nil then
            local orgExpectType = expectType
            if orgExpectType:get_nilable() then
               orgExpectType = orgExpectType:get_nonnilableType()
            end
            
            exp = processsExpectExp( token, orgExpectType )
         else
            self:error( "illegal '.'" )
         end
         
      elseif token.txt == "..." then
         return Nodes.ExpDDDNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeNone}, token )
      elseif token.txt == '[' or token.txt == '[@' then
         exp = self:analyzeListConst( token )
      elseif token.txt == '(@' then
         exp = self:analyzeSetConst( token )
      elseif token.txt == '{' then
         exp = self:analyzeMapConst( token )
      elseif token.txt == "(" then
         exp = self:analyzeExp( false, false )
         self:checkNextToken( ")" )
         exp = Nodes.ExpParenNode.create( self.nodeManager, firstToken.pos, {exp:get_expType()}, exp )
         exp = self:analyzeExpCont( firstToken, exp, false )
      end
      
   end
   
   if token.txt == "new" then
      exp = processsNewExp( token )
   end
   
   if token.kind == Parser.TokenKind.Ope and Parser.isOp1( token.txt ) then
      local workExp, fin = processOp1( token )
      if fin then
         return workExp
      end
      
      exp = workExp
   end
   
   if token.kind == Parser.TokenKind.Int then
      exp = Nodes.LiteralIntNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeInt}, token, math.floor((_lune.unwrapDefault( tonumber( token.txt ), 0) )) )
   elseif token.kind == Parser.TokenKind.Real then
      exp = Nodes.LiteralRealNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeReal}, token, (_lune.unwrapDefault( tonumber( token.txt ), 0.0) ) )
   elseif token.kind == Parser.TokenKind.Char then
      local num = 0
      if #(token.txt ) == 1 then
         num = token.txt:byte( 1 )
      else
       
         num = _lune.unwrap( quotedChar2Code[token.txt:sub( 2, 2 )])
      end
      
      exp = Nodes.LiteralCharNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeChar}, token, num )
   elseif token.kind == Parser.TokenKind.Str then
      local nextToken = self:getToken(  )
      local formatArgList = {}
      if nextToken.txt == "(" then
         local argNodeList = self:analyzeExpList( false, false, nil )
         self:checkNextToken( ")" )
         nextToken = self:getToken(  )
         formatArgList = argNodeList:get_expList()
         self:checkStringFormat( token.pos, token.txt, argNodeList:get_expTypeList() )
      end
      
      exp = Nodes.LiteralStringNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeString}, token, formatArgList )
      token = nextToken
      if token.txt == "[" or token.txt == "$[" then
         exp = self:analyzeExpRefItem( token, exp, token.txt == "$[" )
      else
       
         self:pushback(  )
      end
      
   elseif token.kind == Parser.TokenKind.Symb and token.txt == "__line__" then
      local lineNo = token.pos.lineNo
      if self.macroMode == Nodes.MacroMode.Expand then
         lineNo = self.macroCallLineNo
      end
      
      exp = Nodes.LiteralIntNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeInt}, Parser.Token.new(Parser.TokenKind.Int, string.format( "%d", lineNo), token.pos, false, nil), token.pos.lineNo )
   elseif token.kind == Parser.TokenKind.Kywd and token.txt == "fn" then
      exp = self:analyzeExpSymbol( firstToken, token, ExpSymbolMode.Fn, nil, false )
   elseif token.kind == Parser.TokenKind.Kywd and token.txt == "unwrap" then
      exp = self:analyzeExpUnwrap( token )
   elseif token.kind == Parser.TokenKind.Symb then
      exp = self:analyzeExpSymbol( firstToken, token, ExpSymbolMode.Symbol, nil, false )
      local symbolInfoList = exp:getSymbolInfo(  )
      if #symbolInfoList == 1 then
         local symbolInfo = symbolInfoList[1]
         if symbolInfo:get_kind() == Ast.SymbolKind.Typ then
            exp = self:analyzeRefTypeWithSymbol( Ast.AccessMode.Local, false, false, false, exp )
            local workToken = self:getToken(  )
            if workToken.txt == "." then
               exp = self:analyzeExpSymbol( firstToken, self:getToken(  ), ExpSymbolMode.Field, exp, false )
            else
             
               self:pushback(  )
            end
            
         else
          
            self.scope:accessSymbol( self.moduleScope, symbolInfo )
         end
         
      end
      
   elseif token.kind == Parser.TokenKind.Type then
      local symbolTypeInfo = Ast.sym2builtInTypeMap[token.txt]
      if  nil == symbolTypeInfo then
         local _symbolTypeInfo = symbolTypeInfo
      
         self:error( string.format( "unknown type -- %s", token.txt) )
      end
      
      exp = Nodes.ExpRefNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeNone}, token, Ast.AccessSymbolInfo.new(symbolTypeInfo, nil, false) )
   elseif token.kind == Parser.TokenKind.Kywd and (token.txt == "true" or token.txt == "false" ) then
      exp = Nodes.LiteralBoolNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeBool}, token )
   elseif token.kind == Parser.TokenKind.Kywd and (token.txt == "nil" or token.txt == "null" ) then
      exp = Nodes.LiteralNilNode.create( self.nodeManager, firstToken.pos, {Ast.builtinTypeNil} )
   end
   
   if exp:get_kind() == Nodes.NodeKind.get_None() then
      self:error( "illegal exp" )
   end
   
   if skipOp2Flag then
      return exp
   end
   
   return self:analyzeExpOp2( firstToken, exp, prevOpLevel )
end

function TransUnit:analyzeReturn( token )

   local expList = nil
   local funcTypeInfo = self:getCurrentNamespaceTypeInfo(  )
   if funcTypeInfo == Ast.headTypeInfo or (funcTypeInfo:get_kind() ~= Ast.TypeInfoKind.Func and funcTypeInfo:get_kind() ~= Ast.TypeInfoKind.Method ) then
      self:addErrMess( token.pos, "'return' could not use here" )
   end
   
   local nextToken = self:getToken(  )
   local retTypeList = funcTypeInfo:get_retTypeInfoList()
   if nextToken.txt ~= ";" then
      self:pushback(  )
      expList = self:analyzeExpList( false, false, nil, retTypeList )
      self:checkNextToken( ";" )
   end
   
   if funcTypeInfo:getTxt(  ) == "__init" then
      self:addErrMess( token.pos, "__init method can't return" )
   end
   
   if expList ~= nil then
      do
         local alt2typeMap, newExpNodeList = self:checkMatchType( "return", token.pos, retTypeList, expList, false, not expList:get_followOn(), nil )
         if alt2typeMap ~= nil and newExpNodeList ~= nil then
            expList = newExpNodeList
         end
      end
      
   else
      if #retTypeList ~= 0 then
         self:addErrMess( token.pos, "no return value" )
      end
      
   end
   
   return Nodes.ReturnNode.create( self.nodeManager, token.pos, {Ast.builtinTypeNone}, expList )
end

function TransUnit:analyzeStatement( termTxt )

   local token = self:getTokenNoErr(  )
   if token == Parser.getEofToken(  ) then
      return nil
   end
   
   
   local statement = self:analyzeDecl( Ast.AccessMode.Local, false, token, token )
   if not statement then
      if token.txt == termTxt then
         self:pushback(  )
         return nil
      elseif token.txt == "pub" or token.txt == "pro" or token.txt == "pri" or token.txt == "global" or token.txt == "static" then
         local accessMode = Ast.txt2AccessMode( token.txt )
         if  nil == accessMode then
            local _accessMode = accessMode
         
            accessMode = Ast.AccessMode.Pri
         end
         
         local staticFlag = (token.txt == "static" )
         local nextToken = token
         if token.txt ~= "static" then
            nextToken = self:getToken(  )
         end
         
         statement = self:analyzeDecl( accessMode, staticFlag, token, nextToken )
         if not statement then
            self:addErrMess( nextToken.pos, string.format( "This token is illegal -- %s", nextToken.txt) )
         end
         
      elseif token.txt == "{" then
         self:pushback(  )
         statement = self:analyzeBlock( Nodes.BlockKind.Block, TentativeMode.Simple )
      elseif token.txt == "super" then
         statement = self:analyzeSuper( token )
      elseif token.txt == "if" then
         statement = self:analyzeIf( token )
      elseif token.txt == "when" then
         statement = self:analyzeWhen( token )
      elseif token.txt == "switch" then
         statement = self:analyzeSwitch( token )
      elseif token.txt == "match" then
         statement = self:analyzeMatch( token )
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
         statement = Nodes.BreakNode.create( self.nodeManager, token.pos, {Ast.builtinTypeNone} )
         if #self.loopScopeQueue == 0 then
            self:addErrMess( token.pos, "no loop syntax." )
         end
         
      elseif token.txt == "unwrap" then
         statement = self:analyzeUnwrap( token )
      elseif token.txt == "sync" then
         statement = self:analyzeDeclVar( Nodes.DeclVarMode.Sync, Ast.AccessMode.Local, token )
      elseif token.txt == "import" then
         statement = self:analyzeImport( token )
      elseif token.txt == "subfile" then
         statement = self:analyzeSubfile( token )
      elseif token.txt == "_lune_control" then
         do
            local _exp = self:analyzeLuneControl( token )
            if _exp ~= nil then
               statement = _exp
            else
               statement = self:createNoneNode( token.pos )
            end
         end
         
      elseif token.txt == "provide" then
         statement = self:analyzeProvide( token )
      elseif token.txt == ";" then
         statement = self:createNoneNode( token.pos )
      elseif token.txt == ",," or token.txt == ",,," or token.txt == ",,,," then
         self:error( string.format( "illegal macro op -- %s", token.txt) )
      else
       
         self:pushback(  )
         local exp = self:analyzeExp( true, false )
         local nextToken = self:getToken(  )
         if nextToken.txt == "," then
            exp = self:analyzeExpList( true, true, exp )
            exp = self:analyzeExpOp2( token, exp, nil )
            nextToken = self:getToken(  )
         end
         
         self:checkToken( nextToken, ";" )
         statement = Nodes.StmtExpNode.create( self.nodeManager, exp:get_pos(), {Ast.builtinTypeNone}, exp )
      end
      
   end
   
   if statement ~= nil then
      if not statement:canBeStatement(  ) then
         self:addErrMess( statement:get_pos(), string.format( "This node can't be statement. -- %s", Nodes.getNodeKindName( statement:get_kind() )) )
      end
      
   end
   
   return statement
end

return _moduleObj
