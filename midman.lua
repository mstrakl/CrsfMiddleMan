--
-- My info:
-- Crfs addresses that get through: 0x00 (broadcast) and 0xC8 (fc)
-- Don't send crc bytes -> edge tx computes that
-- 

local function init()
    local x = 0
end


local function serialReadBytes() 

    local bytes = {}
    local strx = serialRead()
    local slen = string.len(strx)

    if (slen > 0) then

        for i = 1,slen,1 do
            bytes[i] = string.byte( strx, i )
        end
    
    else
        slen = 0
        bytes[1] = 0
    end

    return bytes, slen

end


local function packCrsfMsg( payl )

    local cmd = 0
    local out_payl = {}
    local status = false

    if ( #payl >= 4 ) then

        for i = 1, #payl, 1 do

            if (i == 1) then
                cmd = payl[i]
            else
                out_payl[i-1] = payl[i]
            end
        
        end

        status = true
    
    else

        cmd = 0
        out_payl[1] = 0
        status = false

    end

    return cmd, out_payl, status

end



local function run()

    -- # --------------------------------------------------------------- #
    -- Send Telemetry Cmd (0x32) from Serial VCP to FC
    -- # --------------------------------------------------------------- #
    local ser_bytes, ser_len = serialReadBytes()
    local crsf_cmd, crsf_pay, crsf_status = packCrsfMsg( ser_bytes )

    if (crsf_status == true) then

        crossfireTelemetryPush(crsf_cmd, crsf_pay)
        --serialWrite("Push: " .. tostring(crsf_cmd) .. " len=" .. tostring(#crsf_pay) )

    end

    -- # --------------------------------------------------------------- #
    -- Rx Telemetry Cmd (0x32) response from FC and send to Serial VCP
    -- # --------------------------------------------------------------- #

    local ret_cmd, ret_data = crossfireTelemetryPop()
    if ( ret_cmd ~= nil ) then

        serialWrite("CMD ")

        for i = 1, #ret_data, 1 do
            serialWrite(tostring(ret_data[i]) .. " ")
        end

        serialWrite("\n")

    end


    return 0

end

return { init=init, run=run }