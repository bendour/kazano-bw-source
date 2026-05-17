----------- // SCRIPT BY INJ3 
----------- // SCRIPT BY INJ3 
----------- // SCRIPT BY INJ3 
---- // https://steamcommunity.com/id/Inj3/
----
util.AddNetworkString("ipr_optimiser_data")
util.AddNetworkString("ipr_optimiser_upchart")
util.AddNetworkString("ipr_optimiser_custcmd")
util.AddNetworkString("ipr_optimiser_convert")
util.AddNetworkString("ipr_optimiser_rmv")
util.AddNetworkString("ipr_optimiser_prm")
local ipr_mp = game.GetMap() .."/"

if (Improved_System_Map_Optimiser.DL == 1) then
     resource.AddWorkshop("2867746277")
 else
     resource.AddFile("materials/icon/ipr_sys_map_optimiser_icon.png")
end

local function Ipr_ExpPos(ipr_posplayer)
     ipr_posplayer = string.Explode(" ", ipr_posplayer)

     for i = 1, #ipr_posplayer do
        ipr_posplayer[i] = tonumber(math.ceil(ipr_posplayer[i]))
     end
     ipr_posplayer = table.concat(ipr_posplayer, " ")

     return ipr_posplayer
end

local function Ipr_CheckTable(ipr_ent_, ipr_pos_, ipr_table)
     ipr_pos_ = not isstring(ipr_pos_) and tostring(ipr_pos_) or ipr_pos_

     for i = 1, #ipr_table do
        if (Ipr_ExpPos(tostring(ipr_table[i]["ipr_pos"])) == Ipr_ExpPos(ipr_pos_) and ipr_table[i]["ipr_ent"] == ipr_ent_) then
           return true
        end
     end

     return false
end

local function Ipr_ExclAd()
     local ipr_tableplayer_exclude, ipr_classfind = {}, ents.FindByClass("player")
     
     for _, v in ipairs(ipr_classfind) do
        if Improved_System_Map_Optimiser.AdminAccess[v:GetUserGroup()] then
           continue
        end
        table.Add(ipr_tableplayer_exclude, {v})
     end
     
     return ipr_tableplayer_exclude
end

local function Ipr_Checking_DataFile()
     if not file.Exists(Improved_System_Map_Optimiser.RemovedLocation ..ipr_mp, "DATA") then
        file.CreateDir(Improved_System_Map_Optimiser.RemovedLocation ..ipr_mp)
     end
     if not file.Exists(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_removed_props.txt", "DATA") then
        file.Write(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_removed_props.txt", "[]")
     end
     if not file.Exists(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props.txt", "DATA") then
        file.Write(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props.txt", "[]")
     end
     if not file.Exists(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props_convert.txt", "DATA") then
        file.Write(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props_convert.txt", util.TableToJSON({ipr_ent = "prop_physics_multiplayer", ipr_freeze = true, ipr_shadow = true}))
     end
end 

local function Ipr_Optimiser_UpdateData(len, ply, ipr_netreadnb, ipr_table_o, ipr_bool_gui)
     Ipr_Checking_DataFile()
     local Ipr_TableProps = {}
     
     ipr_netreadnb = ipr_netreadnb or net.ReadUInt(2)
     if not istable(ipr_table_o) then
        Ipr_TableProps = (ipr_netreadnb == 2) and file.Read(Improved_System_Map_Optimiser.RemovedLocation .. "" .. ipr_mp .. "_perma_props.txt", "DATA") or file.Read(Improved_System_Map_Optimiser.RemovedLocation .. "" .. ipr_mp .. "_removed_props.txt", "DATA")
     end
     local Ipr_Compress = util.Compress(istable(ipr_table_o) and util.TableToJSON(ipr_table_o) or Ipr_TableProps)
     local Ipr_CompressSize = #Ipr_Compress
  
     net.Start("ipr_optimiser_upchart")
     net.WriteUInt(Ipr_CompressSize, 32)
     net.WriteData(Ipr_Compress, Ipr_CompressSize)
     net.WriteUInt(ipr_netreadnb, 2)
     net.WriteBool(ipr_bool_gui or false)
     if (ply) then
        if istable(ply) then
           net.SendOmit(ply)
        else
           net.Send(ply)
        end
     end
end

local function Ipr_Saving_DataFile_Removed(ipr_ent, ipr_pos, ipr_ply)
     Ipr_Checking_DataFile()

     local Ipr_TableProps = util.JSONToTable(file.Read(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_removed_props.txt", "DATA"))
     local ipr_Ent_Class, ipr_Ply_Nick, ipr_Ent_Model, Ipr_ConvertJson = ipr_ent:GetClass(), ipr_ply:Nick(), ipr_ent:GetModel()
     local Ipr_TableProps_Add = {{["ipr_ent"] = ipr_Ent_Class, ["ipr_pos"] = Ipr_ExpPos(tostring(ipr_pos)), ["ipr_admin"] = ipr_Ply_Nick, ["ipr_customname"] = "[Aucun Nom]", ["ipr_model"] = ipr_Ent_Model, ["ipr_map"] = ipr_ent:MapCreationID()}}
  
     if (#Ipr_TableProps <= 0) then
        Ipr_ConvertJson = util.TableToJSON(Ipr_TableProps_Add)
     else
        if Ipr_CheckTable(ipr_Ent_Class, ipr_pos, Ipr_TableProps) then
           print("Un objet existe déjà sur cette position.")
           return
        end
  
        table.Add(Ipr_TableProps, Ipr_TableProps_Add)
        Ipr_ConvertJson = util.TableToJSON(Ipr_TableProps)
  
        print(ipr_ent, " ajouté dans la base de données. *remove")
     end
  
     ipr_ent:Remove()
     file.Write(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_removed_props.txt", Ipr_ConvertJson)
end

local function Ipr_Saving_DataFile_Perma(ipr_ent, ipr_pos, ipr_angle, ipr_ply)
     Ipr_Checking_DataFile()
     ipr_ent = (ipr_ent:GetClass() ~= "prop_effect") and ipr_ent or ipr_ent:GetChildren()[1]

     local Ipr_TableProps = util.JSONToTable(file.Read(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props.txt", "DATA"))
     local Ipr_TableProps_Convertx = util.JSONToTable(file.Read(Improved_System_Map_Optimiser.RemovedLocation .. "" .. ipr_mp .. "_perma_props_convert.txt", "DATA"))
     local ipr_Ent_Class, ipr_Ent_Model, ipr_Ply_Nick, Ipr_ConvertJson = ipr_ent:GetClass(),  ipr_ent:GetModel(), ipr_ply:Nick()
     local ipr_Ent_Mat, ipr_Ent_Color = ipr_ent:GetMaterial(), ipr_ent:GetColor()
     local Ipr_TableProps_Add = {{["ipr_ent"] = "", ["ipr_pos"] = ipr_pos, ["ipr_angle"] = ipr_angle, ["ipr_model"] = ipr_Ent_Model, ["ipr_index"] = "", ["ipr_admin"] = ipr_Ply_Nick, ["ipr_customname"] = "[Aucun Nom]", ["ipr_class_spec"] = ipr_ent:IsVehicle() and ipr_ent:GetVehicleClass() or ipr_ent:IsNPC() and "IsNpc" or "", ["ipr_customweap"] = ipr_ent:IsNPC() and IsValid(ipr_ent:GetWeapons()[1]) and ipr_ent:GetWeapons()[1]:GetClass() or "", ["ipr_v_freeze"] = Ipr_TableProps_Convertx.ipr_freeze, ["ipr_v_shadow"] = Ipr_TableProps_Convertx.ipr_shadow, ["ipr_mat"] = ipr_Ent_Mat or "", ["ipr_col"] = ipr_Ent_Color or "", ["ipr_collide"] = "0", ["ipr_visible"] = true}}
     if (#Ipr_TableProps <= 0) then
          Ipr_ConvertJson = util.TableToJSON(Ipr_TableProps_Add)
     else
          if Ipr_CheckTable(ipr_Ent_Class, ipr_pos, Ipr_TableProps) then
               print("Un objet existe déjà sur cette position.")
               return
          end
          print(ipr_ent, " ajouté dans la base de données. *perma.")
     end
     local ipr_ent_isvehicle = ipr_ent:IsVehicle() and true or false
     local ipr_ent_isnpcs = ipr_ent:IsNPC() and true or false

     timer.Simple(0.00001, function()
     ipr_Ent_Class = (not ipr_ent_isvehicle and not ipr_ent_isnpcs and Improved_System_Map_Optimiser.ExcludeClassConvert[ipr_Ent_Class]) and Ipr_TableProps_Convertx.ipr_ent or ipr_Ent_Class
     local ipr_props_create = ents.Create(ipr_Ent_Class)

     if (ipr_ent_isvehicle) then
          local Ipr_GetVehClass = list.Get("Vehicles")[ipr_ent:GetVehicleClass()]
          ipr_props_create:SetKeyValue("vehiclescript", Ipr_GetVehClass.KeyValues.vehiclescript)
     end
     if (ipr_ent_isnpcs) then
          local Ipr_List_GetNpc = list.Get("NPC")[ipr_ent:GetClass()]
          if (Ipr_List_GetNpc) then
               if (Ipr_List_GetNpc.KeyValues) then
               for k, v in pairs(Ipr_List_GetNpc.KeyValues) do
                    if (v == nil) then
                         continue
                    end
                    ipr_props_create:SetKeyValue(k, v)
               end
          end

               if (Ipr_List_GetNpc.Skin) then
                    ipr_props_create:SetSkin(Ipr_List_GetNpc.Skin)
               end
               ipr_props_create:SetMaterial(Ipr_List_GetNpc.Material)
          end

          if IsValid(ipr_ent:GetWeapons()[1]) then
               for _, v in pairs(list.Get("NPCUsableWeapons")) do
                    if (v == nil) then
                         continue
                    end
                    if (v.class == ipr_ent:GetWeapons()[1]:GetClass()) then
                         ipr_props_create:SetKeyValue("additionalequipment", v.class)
                         break
                    end
               end
          end
     end
     local ipr_line_save
     if (ipr_Ent_Class == "sammyservers_textscreen") then
          ipr_line_save = ipr_ent.lines
     end
     ipr_ent:Remove()

     ipr_props_create:SetModel(ipr_Ent_Model)
     if (ipr_Ent_Color) then
          ipr_props_create:SetRenderMode(RENDERMODE_TRANSCOLOR)
          ipr_props_create:SetColor(ipr_Ent_Color)
     end
     if not Ipr_List_GetNpc then
          if (ipr_Ent_Mat) then
               ipr_props_create:SetMaterial(ipr_Ent_Mat)
          end
     end
     ipr_props_create:SetPos(Vector(ipr_pos))
     ipr_props_create:SetAngles(Angle(ipr_angle))

     if (DoPropSpawnedEffect) then
     DoPropSpawnedEffect(ipr_props_create)
     end
     ipr_props_create:DrawShadow( Ipr_TableProps_Convertx.ipr_shadow )
     if (ipr_Ent_Class == "sent_ball") then
          ipr_props_create:SetBallSize(math.random(16, 48))
     end
     ipr_props_create:SetKeyValue("fademindist", Improved_System_Map_Optimiser.Dist_Visible)
	ipr_props_create:SetKeyValue("fademaxdist", Improved_System_Map_Optimiser.Dist_Visible + 150)
     ipr_props_create:Spawn()

     ipr_props_create:SetSolid(SOLID_VPHYSICS)
     ipr_props_create:PhysWake() 
     if (ipr_Ent_Class == "sammyservers_textscreen") then
          for i = 1, 5 do
               ipr_props_create:SetLine(
               i,
               ipr_line_save[i]["text"] or "",
               Color(
               ipr_line_save[i]["color"]["r"] or 255,
               ipr_line_save[i]["color"]["g"] or 255,
               ipr_line_save[i]["color"]["b"] or 255,
               ipr_line_save[i]["color"]["a"] or 255
               ),
               ipr_line_save[i]["size"] or 20,
               ipr_line_save[i]["font"]  or 1,
               ipr_line_save[i]["rainbow"] or 0
               )
          end
     end
     if (not ipr_ent_isvehicle or not ipr_ent_isnpcs) then
          if IsValid(ipr_props_create:GetPhysicsObject()) then
               ipr_props_create:GetPhysicsObject():EnableMotion( not Ipr_TableProps_Convertx.ipr_freeze and true or false  )
          end
     end
     for k, v in pairs(Ipr_TableProps_Add) do
          v["ipr_index"] = ipr_props_create:EntIndex()
          v["ipr_ent"] = ipr_Ent_Class

          v["ipr_v_shadow"] = Ipr_TableProps_Convertx.ipr_shadow
          v["ipr_v_freeze"] = Ipr_TableProps_Convertx.ipr_freeze

          if (ipr_Ent_Class == "sammyservers_textscreen") then
               v["ipr_col"] = ipr_line_save
          end
     end
     table.Add(Ipr_TableProps, Ipr_TableProps_Add)
     Ipr_ConvertJson = util.TableToJSON(Ipr_TableProps)

     file.Write(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props.txt", Ipr_ConvertJson)
     if not IsValid(ipr_ply) then
          return
     end
     Ipr_Optimiser_UpdateData(nil, Ipr_ExclAd(), 2, Ipr_TableProps, true)
     Ipr_TableProps, Ipr_TableProps_Convertx = nil, nil
     end)
end

hook.Add("PlayerSay", "Ipr_Optimiser_Chat_Cmd", function(ply, text)
     if (string.lower(text) == string.lower(Improved_System_Map_Optimiser.Command_OpenPanel)) then
         if not IsValid(ply) then
             return
         end
         if not Improved_System_Map_Optimiser.AdminAccess[ply:GetUserGroup()] then
             print("vous n'êtes pas administrateur !")
             return
         end
         net.Start("ipr_optimiser_data")
         net.Send(ply)
 
         return ""
     end
end)

concommand.Add(Improved_System_Map_Optimiser.Command_OpenPanel, function(ply)
     if not IsValid(ply) then
          return
      end
      if not Improved_System_Map_Optimiser.AdminAccess[ply:GetUserGroup()] then
          print("vous n'êtes pas administrateur !")
          return
      end
      net.Start("ipr_optimiser_data")
      net.Send(ply)
end)
 
net.Receive("ipr_optimiser_data", function(len, ply)
     if not IsValid(ply) then 
          return 
     end 
     if not Improved_System_Map_Optimiser.AdminAccess[ply:GetUserGroup()] then
          print("vous n'êtes pas administrateur !")
          return
     end
     local ipr_netreadui = net.ReadUInt(3)
     local ipr_netreadent_ = net.ReadEntity()
     
     if (ipr_netreadui == 2) then
          if file.Exists(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_removed_props.txt", "DATA") then
               file.Write(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_removed_props.txt", "[]")
          end
          Ipr_Optimiser_UpdateData(nil, Ipr_ExclAd(), 1, nil, true)
     elseif (ipr_netreadui == 1) then
          local ipr_tbl_ent_r = util.JSONToTable(file.Read(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props.txt", "DATA"))

          if (#ipr_tbl_ent_r > 0) then
               local Ipr_Class_All_Caching = ents.FindByClass("*")
               local ipr_curdelay_p = 0
     
               for _, v in ipairs(Ipr_Class_All_Caching) do
                    if not isentity(v) then
                         continue
                    end
                    for i = 1, #ipr_tbl_ent_r do
                         if (v:EntIndex() == ipr_tbl_ent_r[i]["ipr_index"]) then
                              ipr_curdelay_p = ipr_curdelay_p + 0.002
     
                              timer.Simple(ipr_curdelay_p, function()
                              if IsValid(v) then
                                   v:Remove()
                              end
                              end)
                         end
                    end
               end
          end             
          if file.Exists(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props.txt", "DATA") then
               file.Write(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props.txt", "[]")
          end
          Ipr_Optimiser_UpdateData(nil, Ipr_ExclAd(), 2, ipr_tbl_ent_r, true)
          ipr_tbl_ent_r = nil
     elseif (ipr_netreadui == 3) then
          Ipr_Optimiser_UpdateData(nil, ply, 2, nil, true)
     elseif (ipr_netreadui == 0) then
          if not IsValid(ipr_netreadent_) then
               return
          end
          Ipr_Saving_DataFile_Removed(ipr_netreadent_, ipr_netreadent_:GetPos(), ply)
          ipr_netreadent_:Remove()
     elseif (ipr_netreadui == 4) then
          print("Le Clean UP de la Map a été effectué !")
          RunConsoleCommand("gmod_admin_cleanup")
     end
end)

local ipr_opti_mat = "Models/effects/vol_light001"     
net.Receive("ipr_optimiser_custcmd", function(len, ply)
     if not IsValid(ply) then 
          return
     end 
     if not Improved_System_Map_Optimiser.AdminAccess[ply:GetUserGroup()] then
          print("vous n'êtes pas administrateur !")
          return
     end
     Ipr_Checking_DataFile()

     local ipr_netreadui_ = net.ReadUInt(4)
     local ipr_Vector = net.ReadString()
     local ipr_readstring = net.ReadString()
     local ipr_netreadbool = net.ReadBool()
     local Ipr_TableProps = {}
     
     if (ipr_netreadui_ == 3) then
          ply:SetPos(Vector(ipr_Vector))
          return
     elseif (ipr_netreadui_ == 2) then
          Ipr_TableProps = util.JSONToTable(file.Read(Improved_System_Map_Optimiser.RemovedLocation .. "" .. ipr_mp .. "_removed_props.txt", "DATA"))
          for i=1, #Ipr_TableProps do
               if (Ipr_ExpPos(tostring(Ipr_TableProps[i]["ipr_pos"])) == Ipr_ExpPos(ipr_Vector)) then
                    Ipr_TableProps[i]["ipr_customname"] = ipr_readstring
                    break
               end
          end
          
          file.Write(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_removed_props.txt", util.TableToJSON(Ipr_TableProps))
          Ipr_Optimiser_UpdateData(nil, Ipr_ExclAd(), 1, Ipr_TableProps, true)
     elseif (ipr_netreadui_ == 1) then
          Ipr_TableProps = util.JSONToTable(file.Read(Improved_System_Map_Optimiser.RemovedLocation .. "" .. ipr_mp .. "_perma_props.txt", "DATA"))
          for i=1, #Ipr_TableProps do
               if (Ipr_ExpPos(tostring(Ipr_TableProps[i]["ipr_pos"])) == Ipr_ExpPos(ipr_Vector)) then
                    Ipr_TableProps[i]["ipr_customname"] = ipr_readstring
                    break
               end
          end

          file.Write(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props.txt", util.TableToJSON(Ipr_TableProps))
          Ipr_Optimiser_UpdateData(nil, Ipr_ExclAd(), 2, Ipr_TableProps, true)
     elseif (ipr_netreadui_ == 4) then
          Ipr_TableProps = util.JSONToTable(file.Read(Improved_System_Map_Optimiser.RemovedLocation .. "" .. ipr_mp .. "_perma_props_convert.txt", "DATA"))

          net.Start("ipr_optimiser_convert")
          net.WriteTable(Ipr_TableProps)
          net.Send(ply)
     elseif (ipr_netreadui_ == 5) then
          Ipr_TableProps = util.JSONToTable(file.Read(Improved_System_Map_Optimiser.RemovedLocation .. "" .. ipr_mp .. "_perma_props.txt", "DATA"))
          for i=1, #Ipr_TableProps do
               if (Ipr_ExpPos(tostring(Ipr_TableProps[i]["ipr_pos"])) == Ipr_ExpPos(ipr_Vector)) then
                    Ipr_TableProps[i]["ipr_ent"] = ipr_readstring
                    break
               end
          end

          file.Write(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props.txt", util.TableToJSON(Ipr_TableProps))
     elseif (ipr_netreadui_ == 6) then
          Ipr_TableProps = util.JSONToTable(file.Read(Improved_System_Map_Optimiser.RemovedLocation .. "" .. ipr_mp .. "_perma_props.txt", "DATA"))
          for i=1, #Ipr_TableProps do
               if (Ipr_ExpPos(tostring(Ipr_TableProps[i]["ipr_pos"])) == Ipr_ExpPos(ipr_Vector)) then
                    Ipr_TableProps[i]["ipr_v_shadow"] = ipr_netreadbool
     
                    local ipr_classfind_c = ents.FindByClass("*")
                    for _, v in ipairs(ipr_classfind_c) do
                         if not isentity(v) then
                              continue
                         end
                         if (tostring(Ipr_TableProps[i]["ipr_index"]) == tostring(v:EntIndex())) then
                              v:DrawShadow(ipr_netreadbool)
                              break
                         end
                    end
                    break
               end
          end
     
          file.Write(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props.txt", util.TableToJSON(Ipr_TableProps))
          Ipr_Optimiser_UpdateData(nil, ply, 2, Ipr_TableProps, true)
     elseif (ipr_netreadui_ == 7) then
          Ipr_TableProps = util.JSONToTable(file.Read(Improved_System_Map_Optimiser.RemovedLocation .. "" .. ipr_mp .. "_perma_props.txt", "DATA"))
          for i=1, #Ipr_TableProps do
               if (Ipr_ExpPos(tostring(Ipr_TableProps[i]["ipr_pos"])) == Ipr_ExpPos(ipr_Vector)) then
                    Ipr_TableProps[i]["ipr_v_freeze"] = ipr_netreadbool
     
                    local ipr_classfind_c = ents.FindByClass("*")
                    for _, v in ipairs(ipr_classfind_c) do
                         if not isentity(v) then
                              continue
                         end
                         if (tostring(Ipr_TableProps[i]["ipr_index"]) == tostring(v:EntIndex())) then
                              local ipr_phys = v:GetPhysicsObject()
                              if IsValid(ipr_phys) then
                                   ipr_phys:EnableMotion(not ipr_netreadbool and true or false)
                                   ipr_phys:Wake()
                                   break
                              end
                         end
                    end
                    break
               end
          end
     
          file.Write(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props.txt", util.TableToJSON(Ipr_TableProps))
          Ipr_Optimiser_UpdateData(nil, ply, 2, Ipr_TableProps, true)
     elseif (ipr_netreadui_ == 8) then
          Ipr_TableProps = util.JSONToTable(file.Read(Improved_System_Map_Optimiser.RemovedLocation .. "" .. ipr_mp .. "_perma_props.txt", "DATA"))
          local ipr_classfind_c = ents.FindByClass("*")
     
          for _, v in ipairs(ipr_classfind_c) do
               if not isentity(v) then
                    continue
               end
               local ipr_ent_isvehicle = v:IsVehicle() and true or false
               local ipr_ent_isnpcs = v:IsNPC() and true or false
               local ipr_ent_index = v:EntIndex()
     
               for i=1, #Ipr_TableProps do
                    if (ipr_ent_index ~= Ipr_TableProps[i]["ipr_index"]) then
                         continue
                    end
                    if (Ipr_ExpPos(tostring(Ipr_TableProps[i]["ipr_pos"])) == Ipr_ExpPos(ipr_Vector)) then
                         local ipr_props_create = ents.Create(Ipr_TableProps[i]["ipr_ent"])
     
                         if ipr_ent_isvehicle then
                              local Ipr_GetVehClass = list.Get("Vehicles")[Ipr_TableProps[i]["ipr_class_spec"]]
                              ipr_props_create:SetKeyValue("vehiclescript", Ipr_GetVehClass.KeyValues.vehiclescript)
                         end
                         if ipr_ent_isnpcs then
                              local Ipr_List_GetNpc = list.Get("NPC")[v:GetClass()]
                              if (Ipr_List_GetNpc) then
                               if (Ipr_List_GetNpc.KeyValues) then
                                   for k, v in pairs(Ipr_List_GetNpc.KeyValues) do
                                        if (v == nil) then
                                             continue
                                        end
                                        ipr_props_create:SetKeyValue(k, v)
                                   end
                              end
                                   if (Ipr_List_GetNpc.Skin) then
                                        ipr_props_create:SetSkin(Ipr_List_GetNpc.Skin)
                                   end
                                   ipr_props_create:SetMaterial(Ipr_List_GetNpc.Material)
                              end
                              if IsValid(v:GetWeapons()[1]) then
                                   for _, v in pairs(list.Get("NPCUsableWeapons")) do
                                        if (v == nil) then
                                             continue
                                        end
                                        if (v.class == Ipr_TableProps[i]["ipr_customweap"]) then
                                             ipr_props_create:SetKeyValue("additionalequipment", v.class)
                                             break
                                        end
                                   end
                              end
                         end
                         v:Remove()
     
                         ipr_props_create:SetModel(Ipr_TableProps[i]["ipr_model"])
                         if (Ipr_TableProps[i]["ipr_mat"] ~= "") then
                              ipr_props_create:SetMaterial(Ipr_TableProps[i]["ipr_mat"])
                         end
                         if (Ipr_TableProps[i]["ipr_col"] ~= "") then
                              ipr_props_create:SetRenderMode(RENDERMODE_TRANSCOLOR)
                              if (Ipr_TableProps[i]["ipr_ent"] ~= "sammyservers_textscreen") then
                              ipr_props_create:SetColor(Ipr_TableProps[i]["ipr_col"])
                              end
                         end
                         ipr_props_create:SetPos(Vector(Ipr_TableProps[i]["ipr_pos"]))
                         ipr_props_create:SetAngles(Angle(Ipr_TableProps[i]["ipr_angle"]))

                         if (DoPropSpawnedEffect) then
                         DoPropSpawnedEffect(ipr_props_create)
                         end
                         ipr_props_create:DrawShadow(Ipr_TableProps[i]["ipr_v_shadow"])
                         if (ipr_Ent_Class == "sent_ball") then
                              ipr_props_create:SetBallSize(math.random(16, 48))
                         end
                         ipr_props_create:SetKeyValue("fademindist", Improved_System_Map_Optimiser.Dist_Visible)
	                    ipr_props_create:SetKeyValue("fademaxdist", Improved_System_Map_Optimiser.Dist_Visible + 150)
                         ipr_props_create:Spawn()

                         ipr_props_create:SetSolid(SOLID_VPHYSICS)
                         ipr_props_create:PhysWake() 
                         if (Ipr_TableProps[i]["ipr_ent"] == "sammyservers_textscreen") then
                              for p = 1, #Ipr_TableProps[i]["ipr_col"] do
                                   ipr_props_create:SetLine(
                                        p, 
                                        Ipr_TableProps[i]["ipr_col"][p]["text"] or "",
                                        Color( 
                                             Ipr_TableProps[i]["ipr_col"][p]["color"]["r"] or 255,
                                             Ipr_TableProps[i]["ipr_col"][p]["color"]["g"] or 255,
                                             Ipr_TableProps[i]["ipr_col"][p]["color"]["b"] or 255,
                                             Ipr_TableProps[i]["ipr_col"][p]["color"]["a"] or 255
                                        ),
                                        Ipr_TableProps[i]["ipr_col"][p]["size"] or 20,
                                        Ipr_TableProps[i]["ipr_col"][p]["font"]  or 1,
                                        Ipr_TableProps[i]["ipr_col"][p]["rainbow"] or 0
                                   )
                              end
                         end
                         ipr_props_create:SetColor(Ipr_TableProps[i]["ipr_visible"] and color_white or color_black)
                         ipr_props_create:SetMaterial(Ipr_TableProps[i]["ipr_visible"] and "" or ipr_opti_mat)
                         ipr_props_create:SetCollisionGroup(tonumber(Ipr_TableProps[i]["ipr_collide"]) or 0)

                         ipr_props_create:SetColor(Ipr_TableProps[i]["ipr_col"])

                         Ipr_TableProps[i]["ipr_index"] = ipr_props_create:EntIndex()

                         if (not ipr_ent_isvehicle or not ipr_ent_isnpcs) then
                              if IsValid(ipr_props_create:GetPhysicsObject()) then
                                   ipr_props_create:GetPhysicsObject():EnableMotion( not Ipr_TableProps[i]["ipr_v_freeze"] and true or false  )
                              end
                         end
                         
                         file.Write(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props.txt", util.TableToJSON(Ipr_TableProps))
                         Ipr_Optimiser_UpdateData(nil, Ipr_ExclAd(), 2, Ipr_TableProps, true)
                         break
                    end
               end
          end
     elseif (ipr_netreadui_ == 9) then   
          Ipr_TableProps = util.JSONToTable(file.Read(Improved_System_Map_Optimiser.RemovedLocation .. "" .. ipr_mp .. "_perma_props.txt", "DATA"))
     
          for i=1, #Ipr_TableProps do
               if (Ipr_ExpPos(tostring(Ipr_TableProps[i]["ipr_pos"])) == Ipr_ExpPos(ipr_Vector)) then
                    Ipr_TableProps[i]["ipr_collide"] = ipr_readstring
     
                    local ipr_classfind_c = ents.FindByClass("*")
                    for _, v in ipairs(ipr_classfind_c) do
                         if not isentity(v) then
                              continue
                         end
                         if (tostring(Ipr_TableProps[i]["ipr_index"]) == tostring(v:EntIndex())) then
                              v:SetCollisionGroup(tonumber(ipr_readstring))
                              break
                         end
                    end
                    break
               end
          end
          file.Write(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props.txt", util.TableToJSON(Ipr_TableProps))
          Ipr_Optimiser_UpdateData(nil, ply, 2, Ipr_TableProps, true) 
     elseif (ipr_netreadui_ == 10) then   
          Ipr_TableProps = util.JSONToTable(file.Read(Improved_System_Map_Optimiser.RemovedLocation .. "" .. ipr_mp .. "_perma_props.txt", "DATA"))
     
          for i=1, #Ipr_TableProps do
               if (Ipr_ExpPos(tostring(Ipr_TableProps[i]["ipr_pos"])) == Ipr_ExpPos(ipr_Vector)) then
                    Ipr_TableProps[i]["ipr_visible"] = ipr_netreadbool
     
                    local ipr_classfind_c = ents.FindByClass("*")
                    for _, v in ipairs(ipr_classfind_c) do
                         if not isentity(v) then
                              continue
                         end
                         if (tostring(Ipr_TableProps[i]["ipr_index"]) == tostring(v:EntIndex())) then
                              v:SetColor(ipr_netreadbool and color_white or color_black)
                              v:SetMaterial(ipr_netreadbool and "" or ipr_opti_mat)
                              break
                         end
                    end
                    break
               end
          end
          file.Write(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props.txt", util.TableToJSON(Ipr_TableProps))
          Ipr_Optimiser_UpdateData(nil, ply, 2, Ipr_TableProps, true) 
     end
     Ipr_TableProps = nil
end)

net.Receive("ipr_optimiser_convert", function(len, ply)
     if not IsValid(ply) then 
          return
     end 
     if not Improved_System_Map_Optimiser.AdminAccess[ply:GetUserGroup()] then
          print("vous n'êtes pas administrateur !")
          return
     end
     local ipr_netreastring = net.ReadString()
     local ipr_netreadbook = net.ReadBool()
     local ipr_netreadbool_shw = net.ReadBool()
     
     if not isstring(ipr_netreastring) or not isbool(ipr_netreadbook) then
          return
     end
     local Ipr_TableProps_Convertp = util.JSONToTable(file.Read(Improved_System_Map_Optimiser.RemovedLocation .. "" .. ipr_mp .. "_perma_props_convert.txt", "DATA"))
     Ipr_TableProps_Convertp.ipr_ent = ipr_netreastring
     Ipr_TableProps_Convertp.ipr_freeze = ipr_netreadbook
     Ipr_TableProps_Convertp.ipr_shadow = ipr_netreadbool_shw
 
     file.Write(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props_convert.txt", util.TableToJSON(Ipr_TableProps_Convertp))
end) 
 
net.Receive("ipr_optimiser_prm", function(len, ply)
     if not IsValid(ply) then 
          return
     end 
     if not Improved_System_Map_Optimiser.AdminAccess[ply:GetUserGroup()] then
          print("vous n'êtes pas administrateur !")
          return
     end
     local ipr_net_readUIint = net.ReadUInt(2)
     local ipr_net_readvector = net.ReadString()
     local ipr_netread = ((ipr_net_readUIint == 1 or ipr_net_readUIint == 2) and net.ReadString() or net.ReadEntity())
     if (ipr_net_readUIint == 3 and not IsValid(ipr_netread)) then
          return
     end
     
     local Ipr_TableProps_Perma = {}
     if (ipr_net_readUIint == 1) then
          Ipr_TableProps_Perma = util.JSONToTable(file.Read(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props.txt", "DATA"))
          local Ipr_Class_All_Caching = ents.FindByClass("*")
     
          if #Ipr_TableProps_Perma >= 1 then
               for i =1, #Ipr_TableProps_Perma do
                     
                    if (Ipr_ExpPos(tostring(Ipr_TableProps_Perma[i]["ipr_pos"])) == Ipr_ExpPos(ipr_net_readvector)) then
                         local ipr_index = Ipr_TableProps_Perma[i]["ipr_index"]
                         table.remove(Ipr_TableProps_Perma, i)
     
                         for _, v in ipairs(Ipr_Class_All_Caching) do
                              if not isentity(v) then
                                   continue
                              end
                              if (v:EntIndex() == ipr_index) then
                                   v:Remove()
                                   break
                              end
                         end
                         break
                    end
               end
          end
          file.Write(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props.txt", util.TableToJSON(Ipr_TableProps_Perma))
          Ipr_Optimiser_UpdateData(nil, Ipr_ExclAd(), 2, Ipr_TableProps_Perma, true)
     elseif (ipr_net_readUIint == 2) then
          Ipr_TableProps_Perma = util.JSONToTable(file.Read(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_removed_props.txt", "DATA"))
     
          if #Ipr_TableProps_Perma >= 1 then
               for i =1, #Ipr_TableProps_Perma do
                    if (Ipr_TableProps_Perma[i]["ipr_ent"] == ipr_netread and Ipr_ExpPos(tostring(Ipr_TableProps_Perma[i]["ipr_pos"])) == Ipr_ExpPos(ipr_net_readvector)) then
                         table.remove(Ipr_TableProps_Perma, i)
                         break
                    end
               end
          end
          file.Write(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_removed_props.txt", util.TableToJSON(Ipr_TableProps_Perma))
          Ipr_Optimiser_UpdateData(nil, ply, 1, Ipr_TableProps_Perma, true)
     else
          local ipr_index_ = ipr_netread:EntIndex()
          Ipr_TableProps_Perma = util.JSONToTable(file.Read(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props.txt", "DATA"))
     
          if #Ipr_TableProps_Perma >= 1 then
               for i =1, #Ipr_TableProps_Perma do
                    if (Ipr_TableProps_Perma[i]["ipr_index"] == ipr_index_ and Ipr_TableProps_Perma[i]["ipr_ent"] == ipr_netread:GetClass()) then
                         table.remove(Ipr_TableProps_Perma, i)
                         break
                    end
               end
               ipr_netread:Remove()
          end
          file.Write(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props.txt", util.TableToJSON(Ipr_TableProps_Perma))
          Ipr_Optimiser_UpdateData(nil, Ipr_ExclAd(), 2, Ipr_TableProps_Perma, true)
     end
end)
     
net.Receive("ipr_optimiser_rmv", function(len, ply)
     if not IsValid(ply) then
         return
     end
     if not Improved_System_Map_Optimiser.AdminAccess[ply:GetUserGroup()] then
         print("vous n'êtes pas administrateur !")
         return
     end
 
     local ipr_net_ReadUi = net.ReadUInt(2)
     local Ipr_net_ReadString = net.ReadEntity()
     if not IsValid(Ipr_net_ReadString) then
         return
     end
     if (ipr_net_ReadUi == 1 and not Ipr_net_ReadString:CreatedByMap()) then
         MsgC("Cette entité n'est pas créé par la map et ne peut être supprimée !")
         return
     end
     local Ipr_EntPos = Ipr_net_ReadString:GetPos()
     if (ply:GetPos():DistToSqr(Ipr_EntPos) > 400000) then
         print("Trop loin de l'entité !")
         return
     end
     if (ipr_net_ReadUi == 1) then
         if (Ipr_net_ReadString:MapCreationID() == -1) then
             return
         end
         Ipr_Saving_DataFile_Removed(Ipr_net_ReadString, Ipr_EntPos, ply)
     elseif (ipr_net_ReadUi == 2) then
         local Ipr_EntAngle = Ipr_net_ReadString:GetAngles()
         Ipr_Saving_DataFile_Perma(Ipr_net_ReadString, Ipr_EntPos, Ipr_EntAngle, ply)
     end
end) 

do
     local function Ipr_Removed_Init()
         Ipr_Checking_DataFile()
         local ipr_tbl_ent_p = util.JSONToTable(file.Read(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props.txt", "DATA"))
         local ipr_tblcn_ent_p = #ipr_tbl_ent_p
         for i = 1, ipr_tblcn_ent_p do
             if timer.Exists("ipr_opti_ent_spawn" ..i) then
                 timer.Remove("ipr_opti_ent_spawn" ..i)
             end
         end
         timer.Create("Ipr_CleanUp_Entity", 1, 1, function()
             local ipr_tbl_ent_r, ipr_tbl_ent_convert = util.JSONToTable(file.Read(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_removed_props.txt", "DATA")), util.JSONToTable(file.Read(Improved_System_Map_Optimiser.RemovedLocation .. "" .. ipr_mp .. "_perma_props_convert.txt", "DATA"))
             local ipr_tblcn_ent_r, ipr_EntIndexRegen = #ipr_tbl_ent_r, false
             if (ipr_tblcn_ent_r > 0) then
                 print("[Improved Removed Props] Nombre d'entités à supprimer :", ipr_tblcn_ent_r)
                 local ipr_curdelay_r = 0
                 for i = 1, ipr_tblcn_ent_r do
                     ipr_curdelay_r = ipr_curdelay_r + Improved_System_Map_Optimiser.DelayRespawnEnt_R
 
                     timer.Simple(ipr_curdelay_r, function()
                         if (Improved_System_Map_Optimiser.ConsolePrint) then
                             print("[Improved Removed Props] Entités supprimées dans la map : \n", ipr_tbl_ent_r[i]["ipr_ent"])
                         end
                         if (ipr_tbl_ent_r[i]["ipr_map"]) then
                         ents.GetMapCreatedEntity(ipr_tbl_ent_r[i]["ipr_map"]):Remove()
                         end
                     end)
                 end
             else
                 print("[Improved Removed Props] : Aucun props ajouté")
             end
             if (ipr_tblcn_ent_p > 0) then
                 print("[Improved Perma Props] Nombre d'entités sauvegardées dans la map :", ipr_tblcn_ent_p)
                 local ipr_curdelay_p = 0
                 for i = 1, ipr_tblcn_ent_p do
                     ipr_curdelay_p = ipr_curdelay_p + Improved_System_Map_Optimiser.DelayRespawnEnt_P
                     timer.Create("ipr_opti_ent_spawn" ..i, ipr_curdelay_p, 1, function()
                         local ipr_props_create = ents.Create(ipr_tbl_ent_p[i]["ipr_ent"])
                         if not IsValid(ipr_props_create) then
                             return MsgC("Attention le model " ..ipr_tbl_ent_p[i]["ipr_ent"].. " [numéro : #" ..i.. "] n'existe plus dans le serveur et ne peut être défini sur la map, supprimer le model dans les options du panel de Improved System Map Optimiser pour éviter de générer cette erreur !\n")
                         end
                         if (ipr_tbl_ent_p[i]["ipr_ent"] == "prop_vehicle_jeep") then
                             local Ipr_GetVehClass = list.Get("Vehicles")[ipr_tbl_ent_p[i]["ipr_class_spec"]]
                             if (Ipr_GetVehClass) then
                                 ipr_props_create:SetKeyValue("vehiclescript", Ipr_GetVehClass.KeyValues.vehiclescript)
                             end
                         end
                         if (ipr_tbl_ent_p[i]["ipr_ent"] == "sammyservers_textscreen" and not (textscreenFonts)) then
                             return
                         end
                         if (ipr_tbl_ent_p[i]["ipr_class_spec"] == "IsNpc") then
                             local Ipr_List_GetNpc = list.Get("NPC")[ipr_tbl_ent_p[i]["ipr_ent"]] or false
                             if (Ipr_List_GetNpc) then
                                 if (Ipr_List_GetNpc.KeyValues) then
                                     for k, v in pairs(Ipr_List_GetNpc.KeyValues) do
                                         if (v == nil) then
                                            continue
                                         end
                                         ipr_props_create:SetKeyValue(k, v)
                                     end
                                 end
                                 if (Ipr_List_GetNpc.Skin) then
                                     ipr_props_create:SetSkin(Ipr_List_GetNpc.Skin)
                                 end
                                 if (Ipr_List_GetNpc.Material) then
                                     ipr_props_create:SetMaterial(Ipr_List_GetNpc.Material)
                                 end
                             end
                             if (ipr_tbl_ent_p[i]["ipr_customweap"] ~= "") then
                                 ipr_props_create:SetKeyValue("additionalequipment", ipr_tbl_ent_p[i]["ipr_customweap"])
                             end
                         end
                         ipr_props_create:SetModel(ipr_tbl_ent_p[i]["ipr_model"])
                         ipr_props_create:SetPos(Vector(ipr_tbl_ent_p[i]["ipr_pos"]))
                         ipr_props_create:SetAngles(Angle(ipr_tbl_ent_p[i]["ipr_angle"]))
 
                         ipr_props_create:DrawShadow(ipr_tbl_ent_p[i]["ipr_v_shadow"])
                         if (ipr_tbl_ent_p[i]["ipr_ent"] == "sent_ball") then
                             ipr_props_create:SetBallSize(math.random(16, 48))
                         end
                         if (ipr_tbl_ent_p[i]["ipr_col"] ~= "") then
                             ipr_props_create:SetRenderMode(RENDERMODE_TRANSCOLOR)
                             if (ipr_tbl_ent_p[i]["ipr_ent"] ~= "sammyservers_textscreen") then
                                 ipr_props_create:SetColor(ipr_tbl_ent_p[i]["ipr_col"])
                             end
                         end
                         if (DoPropSpawnedEffect) then
                             DoPropSpawnedEffect(ipr_props_create)
                         end
                         ipr_props_create:SetKeyValue("fademindist", Improved_System_Map_Optimiser.Dist_Visible)
                         ipr_props_create:SetKeyValue("fademaxdist", Improved_System_Map_Optimiser.Dist_Visible + 150)
                         ipr_props_create:Spawn()

                         ipr_props_create:SetSolid(SOLID_VPHYSICS)
                         ipr_props_create:PhysWake() 
                         if (Improved_System_Map_Optimiser.ConsolePrint) then
                             print("[Improved Perma Props] Entités ajoutés dans la map : \n", ipr_tbl_ent_p[i]["ipr_ent"])
                         end
                         if (ipr_tbl_ent_p[i]["ipr_ent"] == "sammyservers_textscreen") then
                             for p = 1, #ipr_tbl_ent_p[i]["ipr_col"] do
                                 ipr_props_create:SetLine(
                                     p,
                                     ipr_tbl_ent_p[i]["ipr_col"][p]["text"] or "",
                                     Color(
                                         ipr_tbl_ent_p[i]["ipr_col"][p]["color"]["r"]  or 255,
                                         ipr_tbl_ent_p[i]["ipr_col"][p]["color"]["g"]  or 255,
                                         ipr_tbl_ent_p[i]["ipr_col"][p]["color"]["b"]  or 255,
                                         ipr_tbl_ent_p[i]["ipr_col"][p]["color"]["a"]  or 255
                                     ),
                                     ipr_tbl_ent_p[i]["ipr_col"][p]["size"] or 20,
                                     ipr_tbl_ent_p[i]["ipr_col"][p]["font"]  or 1,
                                     ipr_tbl_ent_p[i]["ipr_col"][p]["rainbow"] or 0
                                 )
                             end
                         end
                         if (ipr_tbl_ent_p[i]["ipr_ent"] ~= "prop_vehicle_jeep") then
                             local idp_f
                             if ipr_tbl_ent_p[i]["ipr_v_freeze"] ~= nil then
                                 idp_f = not ipr_tbl_ent_p[i]["ipr_v_freeze"] and true or false
                             else
                                 idp_f = not ipr_tbl_ent_convert.ipr_freeze and true or false
                             end
 
                             if IsValid(ipr_props_create:GetPhysicsObject()) then
                                 ipr_props_create:GetPhysicsObject():EnableMotion(idp_f)
                             end
                         end
                         ipr_props_create:SetColor(ipr_tbl_ent_p[i]["ipr_visible"] and color_white or color_black)
                         ipr_props_create:SetMaterial(ipr_tbl_ent_p[i]["ipr_visible"] and "" or ipr_opti_mat)
                         ipr_props_create:SetCollisionGroup(tonumber(ipr_tbl_ent_p[i]["ipr_collide"]) or 0)
 
                         local ipr_indexcheck = ipr_props_create:EntIndex()

                         if (ipr_tbl_ent_p[i]["ipr_ent"] ~= "sammyservers_textscreen") then
                         ipr_props_create:SetColor(ipr_tbl_ent_p[i]["ipr_col"])
                         end
                         if (ipr_tbl_ent_p[i]["ipr_mat"] ~= "") then
                             ipr_props_create:SetMaterial(ipr_tbl_ent_p[i]["ipr_mat"])
                         end
                         if (ipr_tbl_ent_p[i]["ipr_index"] ~= ipr_indexcheck) then
                             ipr_tbl_ent_p[i]["ipr_index"], ipr_EntIndexRegen = ipr_indexcheck, true
                         end
                         if (ipr_tblcn_ent_p == i) then
                             if (ipr_EntIndexRegen) then
                                 ipr_tbl_ent_p = util.TableToJSON(ipr_tbl_ent_p)
                                 file.Write(Improved_System_Map_Optimiser.RemovedLocation..ipr_mp.. "_perma_props.txt", ipr_tbl_ent_p)
                                 Ipr_Optimiser_UpdateData(nil, Ipr_ExclAd(), 2, ipr_tbl_ent_p, true)
                             end
                         end
                     end)
                 end
             else
                 print("[Improved Perma Props] : Aucun props ajouté")
             end
         end)
     end
     hook.Add("PostCleanupMap", "Ipr_Sytem_Map_Optimiser_PostClean", Ipr_Removed_Init)
     hook.Add("InitPostEntity", "Ipr_Sytem_Map_Optimiser_Init", Ipr_Removed_Init)
end
 
net.Receive("ipr_optimiser_upchart", Ipr_Optimiser_UpdateData)
print("Improved System Map Optimiser v" ..Improved_System_Map_Optimiser.Version.. " loaded !")