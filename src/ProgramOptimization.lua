-- 结合文章：http://www.23cpm.com/view-394623-1.html
-- example1：内存占用
-- 特别注意：由于lua5.1.4版本在调用collectgarbage("collect")进行一次完整gc后，luaC_fullgc会调用setthreshold打开自动gc，
-- 这里容易踩坑，上述代码运行发现内存消耗明显低于lua5.3版本，非常困惑。
-- 所以修改代码在collectgarbage("collect")后，重新调用collectgarbage("stop")关闭自动gc
print("--- example1 ---- ")
collectgarbage("stop")
collectgarbage("collect")
local before = collectgarbage("count")
collectgarbage("stop")
for i=1,10000 do
    local str = "1000000000000000000000000" .. "0"
end

local after = collectgarbage("count")
collectgarbage("stop")
print("[1]mem cost:".. (after - before) .. "K")


before = collectgarbage("count")
collectgarbage("stop")
for i=1,10000 do
    local str = "1000000000000000000000000000000000000000000000000000000".. tostring(i)  -- 测试使用 tostring(i) 和 直接用 i 内存变化 
end

after = collectgarbage("count")
collectgarbage("stop")
print("[2]mem cost:".. (after - before) .. "K")

before = collectgarbage("count")
collectgarbage("stop")
for i=1,10000 do
    local str = string.format( "%s%s","10000000000000000000000000000000000000000000000000000000", tostring(i)) -- 使用string.format 可以减少内存消耗
end
after = collectgarbage("count")
collectgarbage("stop")
print("[3]mem cost:".. (after - before) .. "K")

-- example2：CPU消耗
-- 预填充方式可以避免频繁的表扩容，cpu消耗是动态扩容的1/3
print("--- example2 ---- ")
local time1 = os.clock()
for i=1,1000000 do
    local tab = {["1"] = 1, ["2"] = 2,["3"] = 3, ["4"] = 4, ["5"] = 5} -- 预填充方式
end
local time2 = os.clock()
print("[1] timediff:".. time2 - time1)

time1 = os.clock()
for i=1,1000000 do
    local tab = {} -- 动态扩容
    tab["1"] = 1
    tab["2"] = 2
    tab["3"] = 3
    tab["4"] = 4
    tab["5"] = 5
end
time2 = os.clock()
print("[2] timediff:".. time2 - time1)

-- example3:表结构设计内存优化
-- 以玩家uid作为key，每条记录存积分和名次。分多个场景进行评估
print("--- example3 ---- ")
before = collectgarbage("count")
collectgarbage("stop")
local userSocreRank = {}
for i=1,10000 do
    userSocreRank[i] = {["score"] = i, ["rank"] = i}
end
after = collectgarbage("count")
collectgarbage("stop")
print("[1]user mem cost:".. (after - before) .. "K")

-- 去掉每条子表记录里面的key，直接按有序列表存储
before = collectgarbage("count")
collectgarbage("stop")
local userSocreRank1 = {}
for i=1,10000 do
    userSocreRank1[i] = {i, i}
end
after = collectgarbage("count")
collectgarbage("stop")
print("[2]user mem cost:".. (after - before) .. "K")

-- 如果只有2个变量，可以把两个数值合并，减少一层表的分配
before = collectgarbage("count")
collectgarbage("stop")
local userSocreRank1 = {}
for i=1,10000 do
    userSocreRank1[i] = i*1000000 + i
end
after = collectgarbage("count")
collectgarbage("stop")
print("[3]user mem cost:".. (after - before) .. "K")

-- 如果还要继续压缩内存使用，可以考虑不要存1W条记录，存8192条记录如果也满足要求的话，这样可以减少一次hashtable的预分配。
-- 下面就用8192 和 8193 进行举例
before = collectgarbage("count")
collectgarbage("stop")
local userSocreRank1 = {}
for i=1,8193 do
    userSocreRank1[i] = i*1000000 + i
end
after = collectgarbage("count")
collectgarbage("stop")
print("[4]user(8193) mem cost:".. (after - before) .. "K")

before = collectgarbage("count")
collectgarbage("stop")
local userSocreRank1 = {}
for i=1,8192 do
    userSocreRank1[i] = i*1000000 + i
end
after = collectgarbage("count")
collectgarbage("stop")
print("[5]user(8192) mem cost:".. (after - before) .. "K")

