BM2CONFIG = {}

--Setting this to false will disable the generator from making sound.
BM2CONFIG.GeneratorsProduceSound = true

--Dollas a bitcoins sells for. Dont make this too large or it will be too easy to make money
BM2CONFIG.BitcoinValue = 20500000000

--This is a value that when raising or lowering will effect the speed of all bitminers.
--This is a balanced number and you should only change it if you know you need to. Small increments make big differences
BM2CONFIG.BaseSpeed = 0.005

--The higher this number, the faster the generator will loose fuel.
--You can use this to balance out more so they need to buy fuel more frequently
BM2CONFIG.BaseFuelDepletionRate = 0.6 --0.9 default


--This will allow you to change the default generator output level
BM2CONFIG.GeneratorPowerOutput = 10 --This should only be whole numbers, 10 == 1000W

--These should be 1 by default, changing them high will increase the default
--speed for that bitminer. Making it lower than 1 makes it slower. 
--Remember this is a multiplier so 1 = normal, 2 = twice as fast, 3 = three times as fast, 0.5 = half as slow
BM2CONFIG.BitminerSpeedMulipliers = {
	["bitminerS1"] = 1,
	["bitminerS2"] = 1,
	["bitminerRack"] = 1
}