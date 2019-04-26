-- dig a tree
min_energy = 20
-- where to consume the wood that robot diggs down
textutils.slowPrint("consume the log that dug down ?")
repeat
    print("enter y or n")
    consume_ans = io.read()
until(consume_ans == "y" or consume_ans == "n")
if consume_ans == "y"
then
    consume_ans = true
else
    consume_ans = false
end
-- when the energy is zero, remind you to give it food
if consume_ans
then
    if turtle.getFuelLevel() == 0
    then
        turtle.digUp()
        turtle.refuel(1)
        turtle.up()
    end
else
    if turtle.getFuelLevel() <= min_energy
    then
        turtle.refuel()
        if turtle.getFuelLevel() <= min_energy
        then
            textutils.slowPrint("i am still hungry!")
        end
        -- repeat until you have put something in and fuel level is greater than 20
        repeat
            turtle.refuel()
        until(turtle.getFuelLevel() > min_energy)
    end
    print("energy ", turtle.getFuelLevel())
    textutils.slowPrint("i think i can have a try!")
end
print("working...")
height = 0
--  robot must be able to go back to ground
while true
do
    turtle.digUp()
    turtle.up()
    height = height + 1
    energy = turtle.getFuelLevel()
    -- no logs anymore
    if not turtle.detectUp()
    then
        break
    -- consume logs
    elseif energy == 0 and consume_ans
    then
        turtle.refuel(1)
    -- go back
    elseif height + 1 >= energy and not consume_ans
    then
        break
    else
    end
end
-- while going down, check all the things
while true
do
    if energy == 0 and consume_ans
    then
        turtle.refuel(1)
    end
    detectInf, state = turtle.inspectDown()
    if detectInf == true
    then
        if state.name == "minecraft:vine"
        then
            turtle.digDown()
        else
            break
        end
    end
    turtle.down()
end
print("energy remains ", turtle.getFuelLevel())