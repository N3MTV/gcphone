function TransformerTimeStamp(Value)
    if type(Value) == "userdata" then
        local netType = tostring(Value.GetType())

        if netType == "System.DateTime" then
            return Value.ToUniversalTime().Subtract(clr.System.DateTime(1970, 1, 1)).TotalSeconds
        end

        if netType == "System.Double" then
            return tonumber(tostring(Value))
        end

        if netType == "System.Decimal" then
            return tonumber(tostring(Value))
        end

        if netType == "System.Int32" or netType == "System.UInt32" then
            return tonumber(tostring(Value))
        end

        if netType == "System.Int64" or netType == "System.UInt64" then
            return tonumber(tostring(Value))
        end

        if netType == "System.Boolean" then
            return toboolean(tostring(Value))
        end

        return tostring(Value)
    end
    return Value
end
function MyConvertFieldValue(MysqlDataReader, index)
    if MysqlDataReader.IsDBNull(index) then
        return nil
    end

    -- Some date time cannot be parsed like 0000-01-01
    local status, data = pcall(MysqlDataReader.GetValue, index)

    if status then
        return TransformerTimeStamp(data)
    end

    return nil
end

function MyConvertResultToTable(MySqlDataReader)
    local result = {}

    while MySqlDataReader:Read() do
        local line = {}

        for i=0,MySqlDataReader.FieldCount-1 do
            line[MySqlDataReader.GetName(i)] = MyConvertFieldValue(MySqlDataReader, i);
        end

        result[#result+1] = line;
    end

    MySqlDataReader.Close()
    MySqlDataReader.Dispose()

    return result;
end

function MySQLQueryTimeStamp(query, params)
    local Command = MySQL.Utils.CreateCommand(query, params)
    return MySQL.Sync.wrapQuery(Command.ExecuteReader, Command.Connection, Command.CommandText, MyConvertResultToTable)
end