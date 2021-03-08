-- arbitrary rotation about origin 
function rotateUVW(matrix4x4, u, v, w, theta)
    local m = matrix(matrix4x4)
    local r = matrix({
        {(u^2+(v^2+w^2)*math.cos(theta))/(u^2+v^2+w^2), (u*v*(1-math.cos(theta))-(w*math.sin(theta)*((u^2+v^2+w^2)^(1/2))))/(u^2+v^2+w^2), (u*w*(1-math.cos(theta))+v*((u^2+v^2+w^2)^(1/2))*math.sin(theta))/(u^2+v^2+w^2), 0},
        {(u*v*(1-math.cos(theta))+w*((u^2+v^2+w^2)^(1/2))*math.sin(theta))/(u^2+v^2+w^2), (v^2+(u^2+w^2)*math.cos(theta))/(u^2+v^2+w^2), (v*w*(1-math.cos(theta))-u*((u^2+v^2+w^2)^(1/2))*math.sin(theta))/(u^2+v^2+w^2), 0},
        {(u*w*(1-math.cos(theta))-v*((u^2+v^2+w^2)^(1/2))*math.sin(theta))/(u^2+v^2+w^2), (v*w*(1-math.cos(theta))+u*((u^2+v^2+w^2)^(1/2))*math.sin(theta))/(u^2+v^2+w^2), (w^2+(u^2+v^2)*math.cos(theta))/(u^2+v^2+w^2), 0},
        {0, 0, 0, 1}
    })
    return matrix.mul(m, r)
end

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end

function getPlayerFromPartialName(name)
    local name = name and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil
    if name then
        for _, player in ipairs(getElementsByType("player")) do
            local name_ = getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):lower()
            if name_:find(name, 1, true) then
                return player
            end
        end
    end
end