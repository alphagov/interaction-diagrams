-- grab the passed-in argument(s)
local args = { ... }

-- exit if no arguments were passed in
if #args == 0 then
    return
end

-- a table to hold field extractors
local fields = {}

-- create field extractor(s) for the passed-in argument(s)
for i, arg in ipairs(args) do
    fields[i] = Field.new(arg)
end

-- our fake protocol
local exproto = Proto.new("extractor", "Data Extractor")

-- the new fields that contain the extracted data (one in string form, one in hex)
local exfield_string = ProtoField.new("Extracted String Value", "extractor.value.string", ftypes.STRING)
local exfield_hex    = ProtoField.new("Extracted Hex Value", "extractor.value.hex", ftypes.STRING)

-- register the new fields into our fake protocol
exproto.fields = { exfield_string, exfield_hex }

function exproto.dissector(tvbuf,pktinfo,root)
    local tree = nil

    for i, field in ipairs(fields) do
        -- extract the field into a table of FieldInfos
        finfos = { field() }

        if #finfos > 0 then
            -- add our proto if we haven't already
            if not tree then
                tree = root:add(exproto)
            end

            for _, finfo in ipairs(finfos) do
                -- get a TvbRange of the FieldInfo
                local ftvbr = finfo.tvb
                tree:add(exfield_string, ftvbr:string(ENC_UTF_8))
                tree:add(exfield_hex,tostring(ftvbr:bytes()))
            end
        end
    end

end

register_postdissector(exproto, true)
