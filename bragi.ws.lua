bragi_proto = Proto("bragi", "Corsair Bragi protocol")


--[[local commands = {
    [0x00] = "Return",
    --[0x01] = "HID Event",
    [0x08] = "Everything"
}]]--

local targets = {
    [0x00] = "Host?",
    [0x08] = "Device"
}

local commands = {
    [0x00] = "HID Event",
    [0x01] = "Set",
    [0x02] = "Get",
    [0x05] = "Dunno 0x5", -- default???
    [0x06] = "Logo/Bootloader/Scale?",
    [0x07] = "Write Multiple",
    [0x0d] = "Dunno 0x6"
}

-- for 0x01 and 0x02 commands, but 0x06 should also not overlap, so they may as well be there. Not sure about 0x05
local subcommands = {
    [0x01] = "Polling rate",
    [0x02] = "Brightness",
    [0x03] = "Mode",
    [0x11] = "Vendor ID",
    [0x12] = "Product ID",
    [0x13] = "Firmware version",
    [0x14] = "Bootloader version",

    -- oh boy, DPI
    [0x18] = "1st mode DPI value",
    [0x19] = "2nd mode DPI value",
    [0x1a] = "3th mode DPI value",
    [0x1b] = "4th mode DPI value",
    [0x1c] = "5th mode DPI value",

    [0x1e] = "DPI something",
    [0x1f] = "enabled DPI modes",

    [0x20] = "Default DPI/*current DPI*?",

    [0x2f] = "1st mode DPI color",
    [0x30] = "2nd mode DPI color",
    [0x31] = "3rd mode DPI color",
    [0x32] = "4th mode DPI color",
    [0x33] = "5th mode DPI color",


    [0x52] = "Handedness",
    [0x5f] = "Dunno, it was GETted during init"
}

local control_types = {
    [0x01] = "Hardware",
    [0x02] = "Software",
    [0x03] = "Firmware?"
}

local Handednesses = {
    [0x00] = "Right hand",
    [0x01] = "Left hand",
}

-- local reset_types = {}

-- local control_types = {}

-- local colour_types = {}

local vendor_ids = {
    [0x1b1c] = "Corsair"
}

local product_ids = {
    [0x1b70] = "M55 RGB PRO"
}

--[[local product_ids_blacklist = {
    [0x1b3d] = "K55 RGB",
    [0x1b40] = "K63",
    [0x1b17] = "K65 RGB",
    [0x1b07] = "K65",
    [0x1b37] = "K65 LUX RGB",
    [0x1b39] = "K65 RAPIDFIRE",
    [0x1b3f] = "K68",
    [0x1b4f] = "K68 RGB",
    [0x1b13] = "K70 RGB",
    [0x1b09] = "K70",
    [0x1b33] = "K70 LUX RGB",
    [0x1b36] = "K70 LUX",
    [0x1b38] = "K70 RAPIDFIRE RGB",
    [0x1b3a] = "K70 RAPIDFIRE",
    [0x1b49] = "K70 RGB MK.2",
    [0x1b11] = "K95 RGB",
    [0x1b08] = "K95",
    [0x1b2d] = "K95 PLATINUM RGB",
    [0x1b20] = "STRAFE RGB",
    [0x1b48] = "STRAFE RGB MK.2",
    [0x1b15] = "STRAFE",
    [0x1b44] = "STRAFE",
    [0x1b12] = "M65 RGB",
    [0x1b2e] = "M65 PRO RGB",
    [0x1b14] = "SABRE RGB",
    [0x1b19] = "SABRE RGB",
    [0x1b2f] = "SABRE RGB",
    [0x1b32] = "SABRE RGB",
    [0x1b1e] = "SCIMITAR RGB",
    [0x1b3e] = "SCIMITAR PRO RGB",
    [0x1b3c] = "HARPOON RGB",
    [0x1b34] = "GLAIVE RGB",
    [0x1b22] = "KATAR",
    [0x1b35] = "DARK CORE RGB",
    [0x1b64] = "DARK CORE RGB Dongle",
    [0x1b3b] = "MM800 RGB POLARIS",
    [0x1b2a] = "VOID RGB"
}]]--

--[[local device_types = {
    [0xc0] = "Keyboard",
    [0xc1] = "Mouse",
    [0xc2] = "Mousepad"
}]]--

--[[local layout_types = {
    [0x00] = "ANSI",
    [0x01] = "ISO",
    [0x02] = "ABNT",
    [0x03] = "JIS",
    [0x04] = "Dubeolsik"
}]]--

--[[local hwprofile_commands = {
    [0x01] = "Get Buffer Size",
    [0x03] = "Get File Size",
    [0x04] = "Get File List",
    [0x05] = "Write to Filename",
    [0x07] = "Switch to File",
    [0x08] = "End File",
    [0x09] = "Write Segment",
    [0x0a] = "Set Read Mode",
    [0x0b] = "Set Write Mode",
    [0x0c] = "Switch Hardware Mode",
    [0x0d] = "Get Last Status"
}]]--

local button_presses = {
    [0] = "Not pressed",
    [1] = "Pressed"
}

local f = bragi_proto.fields

-- Target? I only can guess, it was always 0x08 or 0x00 for me
f.target = ProtoField.uint8("bragi.target", "Target", base.HEX, targets)

-- Root commands
f.cmd = ProtoField.uint8("bragi.command", "Command", base.HEX, commands)

-- Subcommands
f.subcmd = ProtoField.uint8("bragi.subcommand", "Subcommand", base.HEX, subcommands)

-- Control Subcommands
f.special_mode = ProtoField.uint8("bragi.special_function.mode", "Special Function Control Mode", base.DEC, control_types)

-- FW identification fields
f.ident_fwver = ProtoField.uint16("bragi.ident.fwver", "Firmware Version", base.HEX)
f.ident_bldver = ProtoField.uint16("bragi.ident.bldver", "Bootloader Version", base.HEX)
f.ident_vendor = ProtoField.uint16("bragi.ident.vendor", "USB Vendor ID", base.HEX, vendor_ids)
f.ident_product = ProtoField.uint16("bragi.ident.product", "USB Product ID", base.HEX, product_ids)
-- f.ident_pollrate = ProtoField.uint8("bragi.ident.pollrate", "Poll Rate (msec)", base.DEC)
-- f.ident_devtype = ProtoField.uint8("bragi.ident.device_type", "Device Type", base.HEX, device_types)

--Buttons
f.button_left = ProtoField.uint8("bragi.mouse.buttons.left", "Left mouse button", base.HEX, button_presses, 0x01)
f.button_right = ProtoField.uint8("bragi.mouse.buttons.right", "Right mouse button", base.HEX, button_presses, 0x02)
f.button_scroll = ProtoField.uint8("bragi.mouse.buttons.scroll", "Scroll mouse button", base.HEX, button_presses, 0x04)
f.button_left_side_bottom = ProtoField.uint8("bragi.mouse.buttons.left_side_bottom", "Left side bottom mouse button", base.HEX, button_presses, 0x08)
f.button_left_side_top = ProtoField.uint8("bragi.mouse.buttons.left_side_top", "Left side top mouse button", base.HEX, button_presses, 0x10)
f.button_right_side_bottom = ProtoField.uint8("bragi.mouse.buttons.right_side_bottom", "Right side bottom mouse button", base.HEX, button_presses, 0x20)
f.button_right_side_top = ProtoField.uint8("bragi.mouse.buttons.right_side_top", "Right side top mouse button", base.HEX, button_presses, 0x40)
f.button_dpi = ProtoField.uint8("bragi.mouse.buttons.dpi", "DPI mouse button", base.HEX, button_presses, 0x80)

function has_index (tab, key)
    return tab[key] ~= nil
end

function bragi_proto.dissector(buffer, pinfo, tree)
    -- Bragi packets are 64 bytes long
    if buffer:len() ~= 64 then
        return
    end

    local offset = 0
    local target = buffer(offset, 1)
    offset = offset + 1

    local command = buffer(offset, 1)
    offset = offset + 1

    -- Exclude unknown packet headers
    if has_index(commands, command:uint()) ~= true then
        return
    end
    
    pinfo.cols["protocol"] = "Bragi"
    local t_bragi = tree:add(bragi_proto, buffer())

    t_bragi:add(f.target, target)
    target = target:uint()
    --[[if target == 0x00 then
        pinfo.cols["info"] = "Receive"
    else
        pinfo.cols["info"] = "Send"
    end]]--

    --local t_bragi = tree:add(bragi_proto, buffer())
    t_bragi:add(f.cmd, command)
    command = command:uint()
    --t_bragi:add(f.raw, payload)
    
    -- it's ony subcommand if the target is not 0x00
    if target ~= 0x00 then
        local subcommand = buffer(offset,2)
        offset = offset + 2
        t_bragi:add_le(f.subcmd, subcommand)
        subcommand = subcommand:le_uint()
        
        if command == 0x01 and subcommand == 0x03 then
            local mode = buffer(offset, 1)
            offset = offset + 1
            t_bragi:add(f.special_mode, mode)
        end
    elseif target == 0x00 then
        if command == 0x02 then
            -- It is response to whatever then
            local buttons = buffer(offset, 1)
            offset = offset + 1
            t_bragi:add(f.button_left, buttons)
            t_bragi:add(f.button_right, buttons)
            t_bragi:add(f.button_scroll, buttons)
            t_bragi:add(f.button_left_side_bottom, buttons)
            t_bragi:add(f.button_left_side_top, buttons)
            t_bragi:add(f.button_right_side_bottom, buttons)
            t_bragi:add(f.button_right_side_top, buttons)
            t_bragi:add(f.button_dpi, buttons)


            local value = buffer(offset, buffer:len() - offset)
            -- t_bragi:add(f.)
        end
    end
end

usb_table = DissectorTable.get("usb.interrupt")
usb_table:add(0x03, bragi_proto)
usb_table:add(0xffff, bragi_proto)
