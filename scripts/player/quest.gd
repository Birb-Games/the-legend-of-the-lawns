class_name Quest

class Goal:
	var description: String
	# Should be of the form func(Main) -> bool
	var completed: Callable

	func _init(desc: String, completed_func: Callable) -> void:
		self.completed = completed_func
		self.description = desc

class Reward:
	var description: String
	# Should be of the form func(Main) -> void
	var give: Callable
	var secret: bool = false

	func _init(desc: String, give_func: Callable) -> void:
		self.give = give_func
		self.description = desc
	
	static func secret_reward(desc: String, give_func: Callable) -> Reward:
		var reward: Reward = Reward.new(desc, give_func)
		reward.secret = true
		return reward

var reward: Reward
var goals: Array = []

static func completed_neighbors(neighbors: Array) -> bool:
	for neighbor: NeighborNPC in neighbors:
		if neighbor.times_mowed <= 0:
			return false
	return true

func completed(main: Main) -> bool:
	for goal: Goal in goals:
		if !goal.completed.call(main):
			return false
	return completed_neighbors(main.get_current_neighbors())

func give_reward(main: Main) -> void:
	reward.give.call(main)

func _init(quest_reward: Reward, goal_list: Array) -> void:
	reward = quest_reward
	goals = goal_list

static func talked_to_npc(main: Main, path: String) -> bool:
	var npc: NPC = main.neighborhood.get_node(path)
	return !npc.first_time

# List of quests
static var list: Array[Quest] = [
	# Quest 0
	Quest.new(
		Reward.new(
			"", 
			func(_main: Main) -> void: pass
		),
		[
			Goal.new(
				"Ask Mom about the new Swapdeck.", 
				func(main: Main) -> bool: return talked_to_npc(main, "Intro/MomIntro")
			),
			Goal.new(
				"Ask Dad about the new Swapdeck.", 
				func(main: Main) -> bool: return talked_to_npc(main, "Intro/DadIntro")
			),
		]
	),
	
	# Quest 1
	Quest.new(
		Reward.new(
			"$1", 
			func(main: Main) -> void: main.money += 1
		),
		[
			Goal.new(
				"Talk to the government job man at the job board by the store.",
				func(main: Main) -> bool: return talked_to_npc(main, "NPCs/MrGovJobMan")
			)
		]
	),
	
	# Quest 2
	Quest.new(
		Reward.new(
			"$2", 
			func(main: Main) -> void: main.money += 2
		),
		[]
	),
	
	# Quest 3
	Quest.new(
		Reward.new(
			"$3", 
			func(main: Main) -> void: main.money += 3
		),
		[]
	),

	# Quest 4
	Quest.new(
		Reward.new(
			"$4", 
			func(main: Main) -> void: main.money += 4
		),
		[
			Goal.new(
				"Talk to your friend Carlos in Neighbor Nancy's yard.",
				func(main: Main) -> bool: return talked_to_npc(main, "NPCs/Carlos")
			)
		]
	),
	
	# Quest 5
	Quest.new(
		Reward.new(
			"$6",
			func(main: Main) -> void: main.money += 6
		),
		[]
	),
	
	# Quest 6
	Quest.new(
		Reward.new(
			"$5",
			func(main: Main) -> void: main.money += 5
		),
		[
			Goal.new(
				"Talk to Mr. Manager at the store.",
				func(main: Main) -> bool: return talked_to_npc(main, "Store/MrManager")
			),
			Goal.new(
				"Talk to the new robot employee at the store.", 
				func(main: Main) -> bool: return talked_to_npc(main, "Store/Robot")
			),
		]
	),

	# Quest 7
	Quest.new(
		Reward.new(
			"$6",
			func(main: Main) -> void: main.money += 6
		),
		[]
	),

	# Quest 8
	Quest.new(
		Reward.new(
			"$5",
			func(main: Main) -> void: main.money += 5
		),
		[]
	),

	# Quest 9
	Quest.new(
		Reward.new(
			"$7",
			func(main: Main) -> void: main.money += 7
		),
		[]
	),

	# Quest 10
	Quest.new(
		Reward.new(
			"$1",
			func(main: Main) -> void: main.money += 1
		),
		[
			Goal.new(
				"Talk to IT Girl at the store.", 
				func(main: Main) -> bool: return talked_to_npc(main, "Store/ITGirl")
			),
		]
	),

	# Quest 11
	Quest.new(
		Reward.new(
			"$7",
			func(main: Main) -> void: main.money += 7
		),
		[]
	),

	# Quest 12
	Quest.new(
		Reward.new(
			"$1",
			func(main: Main) -> void: main.money += 1
		),
		[
			Goal.new(
				"Talk to IT Girl at the store.", 
				func(main: Main) -> bool: return talked_to_npc(main, "Store/ITGirl2")
			),
		]
	),

	# Quest 13
	Quest.new(
		Reward.new(
			"Swapdeck available in store!",
			func(main: Main) -> void: main.money -= 100
		),
		[
			Goal.new(
				"Earn $100 to pay IT Girl's\nsmuggling fee.",
				func(main: Main) -> bool: return main.money >= 100
			),
		]
	),

	# Quest 14
	Quest.new(
		Reward.new(
			"$1",
			func(main: Main) -> void: main.money += 1
		),
		[
			Goal.new(
				"Talk to IT Girl at the store.", 
				func(main: Main) -> bool: return talked_to_npc(main, "Store/ITGirl3")
			),
		]
	),
	
	# Quest 15
	Quest.new(
		Reward.new(
			"$8",
			func(main: Main) -> void: main.money += 8
		),
		[]
	),

	# Quest 16
	Quest.new(
		Reward.new(
			"$1",
			func(main: Main) -> void: main.money += 1
		),
		[
			Goal.new(
				"Talk to IT Girl at the store.", 
				func(main: Main) -> bool: return talked_to_npc(main, "Store/ITGirl4")
			),
		]
	),

	# Quest 17
	Quest.new(
		Reward.new(
			"$8 + RAM",
			func(main: Main) -> void: main.money += 8
		),
		[]
	),

	# Quest 18
	Quest.new(
		Reward.new(
			"$1",
			func(main: Main) -> void: main.money += 1
		),
		[
			Goal.new(
				"Talk to IT Girl at the store.", 
				func(main: Main) -> bool: return talked_to_npc(main, "Store/ITGirl5")
			),
		]
	),

	# Quest 19
	Quest.new(
		Reward.new(
			"$8 + GPU",
			func(main: Main) -> void: main.money += 8
		),
		[]
	),

	# Quest 20
	Quest.new(
		Reward.new(
			"$5",
			func(main: Main) -> void: main.money += 5
		),
		[
			Goal.new(
				"Talk to IT Girl at the store.", 
				func(main: Main) -> bool: return talked_to_npc(main, "Store/ITGirl6")
			),
			Goal.new(
				"Talk to Mr. Manager at the store.", 
				func(main: Main) -> bool: return talked_to_npc(main, "Store/MrManager2")
			),
		]
	),

	# Quest 21
	Quest.new(
		Reward.new(
			"$8",
			func(main: Main) -> void: main.money += 8
		),
		[]
	),

	# Quest 22
	Quest.new(
		Reward.new(
			"$1",
			func(main: Main) -> void: main.money += 1; main.player.inventory.has_alien_battery = false
		),
		[
			Goal.new(
				"Talk to IT Girl at the store.", 
				func(main: Main) -> bool: return talked_to_npc(main, "Store/ITGirl7")
			),
		]
	),

	# Quest 23
	Quest.new(
		Reward.new(
			"$10",
			func(main: Main) -> void: main.money += 10
		),
		[]
	),

	# Quest 24
	Quest.new(
		Reward.new(
			"Your very own Swapdeck!",
			func(_main: Main) -> void: pass
		),
		[
			Goal.new(
				"Buy the Swapdeck!", 
				func(_main: Main) -> bool: return false
			),
		]
	),

	# Quest 25
	Quest.new(
		Reward.new(
			"",
			func(_main: Main) -> void: pass
		),
		[
			Goal.new(
				"Talk to IT Girl", 
				func(main: Main) -> bool: return talked_to_npc(main, "SecretLab/ITGirl")
			),
			Goal.new(
				"Talk to Willow", 
				func(main: Main) -> bool: return talked_to_npc(main, "SecretLab/Willow")
			),
		]
	),

	# Quest 26
	Quest.new(
		Reward.secret_reward(
			"$999999",
			func(main: Main) -> void: main.money += 999999
		),
		[]
	),
]

static func get_quest(index: int) -> Quest:
	if index >= 0 and index < list.size():
		return list[index]
	return null
