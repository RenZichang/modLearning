--[[假设：
方块毗邻指同层或上层或下层九宫格中有另一个方块
minecraft中的树木所有木头方块都是毗邻的]]
-- 深拷贝
function DeepCopy( obj )	
	local InTable = {};
	local function Func(obj)
		if type(obj) ~= "table" then   --判断表中是否有表
			return obj;
		end
		local NewTable = {};  --定义一个新表
		InTable[obj] = NewTable;  --若表中有表，则先把表给InTable，再用NewTable去接收内嵌的表
		for k,v in pairs(obj) do  --把旧表的key和Value赋给新表
			NewTable[Func(k)] = Func(v);
		end
		return setmetatable(NewTable, getmetatable(obj))--赋值元表
	end
	return Func(obj) --若表中有表，则把内嵌的表也复制了
end
--------------------- 
--[[作者：瑟提曼的海 
来源：CSDN 
原文：https://blog.csdn.net/qq_32319583/article/details/53383935 
版权声明：本文为博主原创文章，转载请附上博文链接！]]
-- 全局变量，当前位置、方向向量以及结点队列
position_now = {0, 0, 0}
direction = {{0, 1 ,0}, {1, 0, 0}, {0, -1, 0}, {-1, 0, 0}}
direction_pt = 1
queue = {position_now}
queue_pt = 1
-- 自定义转向函数
function myTurnLeft()
    turtle.turnLeft()
    direction_pt = direction_pt % 4 + 1
end
function myTurnRight()
    turtle.turnRight()
    direction_pt = (direction_pt - 2) % 4 + 1 
end
-- 自定义前移函数
function myForward()
    turtle.dig()
    turtle.forward()
    for i=1,3
    do
        position_now[i] = position_now[i] + direction[direction_pt][i]
    end
end
-- 移动函数，保持朝向不变
function move(position)
    -- 保存方向向量
    direction_res = direction_pt
    -- 初始位移
    displacement = {}
    for i_2=1,3
    do
        displacement[i_2] = position[i_2] - position_now[i_2]
    end
    -- 二维，左右移动
    for i_1=1,2
    do
        -- 调整方向
        while displacement[i_1]*direction[direction_pt][i_1] <= 0 and displacement[i_1] ~= 0
        do
            myTurnLeft()
        end
        -- 调整好方向，前进
        while position_now[i_1] ~= position[i_1]
        do
            myForward()
        end
    end
    -- 上下移动
    if displacement[3] > 0
    then
        while position_now[3] ~= position[3]
        do
            turtle.digUp()
            turtle.up()
            position_now[3] = position_now[3] + 1
        end
    elseif displacement[3] < 0
    then
        while position_now[3] ~= position[3]
        do
            turtle.digDown()
            turtle.down()
            position_now[3] = position_now[3] - 1
        end
    else
    end
    -- 调整回原来的方向
    while direction_pt ~= direction_res
    do
        myTurnRight()
    end
end
-- 检测函数，检测该方向是否有原木
function detectLog(orientation)
    -- 参数0代表检测前方，其他参数代表检测上方
    if orientation == 0
    then
        detBlk, state = turtle.inspect()
    else
        detBlk, state = turtle.inspectUp()
    end
    -- 字符串匹配
    if detBlk and string.find(state.name, "log")
    then
        return true
    else
        return false
    end
end
-- 坐标函数，根据当前朝向 计算 方块的绝对坐标
function getPos(orientation)
    pos = DeepCopy(position_now)
    -- 传入参数0表示面向的方块
    if orientation == 0
    then
        for i_1=1,3
        do
            pos[i_1] = pos[i_1] + direction[direction_pt][i_1]
        end
    else
        pos[3] = pos[3] + 1
    end
    return pos
end
-- 入队函数，当且仅当没有入过队才入队
function pushQueue(position)
    for i_1=1,queue_pt
    do
        same = true
        for i_2=1,3
        do
            same = same and (position[i_2] == queue[i_1][i_2])
        end
        if same
        then
            return false
        end
    end
    table.insert(queue, position)
    return true
end
function main()
    -- 当没有越界访问时
    while queue_pt <= #queue
    do
        -- 走到指定的位置
        move(queue[queue_pt])
        -- 遍历九宫格的八个格子，如果有木头，就记录坐标
        for i_1=1,4
        do
            for i_2=1,2
            do
                -- 右转
                myTurnRight()
                -- 若前面有木头
                if detectLog(0)
                then
                    -- 木头位置入队
                    pushQueue(getPos(0))
                end
                -- 前进一格
                myForward()
                -- 若上面有木头
                if detectLog(1)
                then
                    -- 木头位置入队
                    pushQueue(getPos(1))
                end
            end
            -- 调整方向
            for i_2=1,2
            do
                myTurnRight()
            end
            -- 原路返回
            myForward()
            myTurnLeft()
            myForward()
        end
        -- 若上方有木头
        if detectLog(1)
        then
            -- 木头位置入队
            pushQueue(getPos(1))
        end
        -- 指针后移
        queue_pt = queue_pt + 1
    end
end
energy = turtle.getFuelLevel()
print(energy)
while energy < 1000
do
    turtle.refuel()
end
main()
print(turtle.getFueLevel())