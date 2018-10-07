local diditload = false
local dff,txd
function loadBTWheels(load)  
  if load == true then
    txd = engineLoadTXD("wheels/bt/j2_wheels.txd", 1082 )
    engineImportTXD(txd, 1082)
    dff = engineLoadDFF("wheels/bt/wheel_gn1.dff", 1082 )
    engineReplaceModel(dff, 1082) 
    dff = engineLoadDFF("wheels/bt/wheel_gn2.dff", 1085 )
    engineReplaceModel(dff, 1085) 
    dff = engineLoadDFF("wheels/bt/wheel_gn3.dff", 1096 )
    engineReplaceModel(dff, 1096)
    dff = engineLoadDFF("wheels/bt/wheel_gn4.dff", 1097 )
    engineReplaceModel(dff, 1097)
    dff = engineLoadDFF("wheels/bt/wheel_gn5.dff", 1098 )
    engineReplaceModel(dff, 1098)
    dff = engineLoadDFF("wheels/bt/wheel_sr1.dff", 1079 )
    engineReplaceModel(dff, 1079) 
    dff = engineLoadDFF("wheels/bt/wheel_sr2.dff", 1075 )
    engineReplaceModel(dff, 1075)
    dff = engineLoadDFF("wheels/bt/wheel_sr3.dff", 1074 )
    engineReplaceModel(dff, 1074)
    dff = engineLoadDFF("wheels/bt/wheel_sr4.dff", 1081 )
    engineReplaceModel(dff, 1081)
    dff = engineLoadDFF("wheels/bt/wheel_sr5.dff", 1080 )
    engineReplaceModel(dff, 1080) 
    dff = engineLoadDFF("wheels/bt/wheel_sr6.dff", 1073 )
    engineReplaceModel(dff, 1073)
    dff = engineLoadDFF("wheels/bt/wheel_lr1.dff", 1077 )
    engineReplaceModel(dff, 1077)
    dff = engineLoadDFF("wheels/bt/wheel_lr2.dff", 1083 )
    engineReplaceModel(dff, 1083)
    dff = engineLoadDFF("wheels/bt/wheel_lr3.dff", 1078 )
    engineReplaceModel(dff, 1078)
    dff = engineLoadDFF("wheels/bt/wheel_lr4.dff", 1076 )
    engineReplaceModel(dff, 1076)
    dff = engineLoadDFF("wheels/bt/wheel_lr5.dff", 1084 )
    engineReplaceModel(dff, 1084)
    dff = engineLoadDFF("wheels/bt/wheel_or1.dff", 1025 )
    engineReplaceModel(dff, 1025)
    diditload = true
  elseif load == false and diditload == true then
    if isElement(txd) then destroyElement(txd) end
    engineRestoreModel(1082)
    engineRestoreModel(1085)
    engineRestoreModel(1096)
    engineRestoreModel(1097)
    engineRestoreModel(1098)
    engineRestoreModel(1079)
    engineRestoreModel(1075)
    engineRestoreModel(1074)
    engineRestoreModel(1081)
    engineRestoreModel(1080)
    engineRestoreModel(1073)
    engineRestoreModel(1077)
    engineRestoreModel(1083)
    engineRestoreModel(1078)
    engineRestoreModel(1076)
    engineRestoreModel(1084)
    engineRestoreModel(1025)
    -- outputDebugString("Chrome Wheels unloaded")
          triggerEvent("onBtWheelsUnload", getResourceRootElement())
    diditload = false
  end
end






