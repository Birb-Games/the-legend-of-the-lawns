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

	func _init(desc: String, give_func: Callable) -> void:
		self.give = give_func
		self.description = desc

var reward: Reward
var goals: Array = []

static func completed_neighbors(neighbors: Array) -> bool:
	for neighbor: NeighborNPC in neighbors:
		if neighbor.times_mowed <= 0:
			return false
	return true

func completed(main: Main, neighbors: Array) -> bool:
	for goal: Goal in goals:
		if !goal.completed.call(main):
			return false
	return completed_neighbors(neighbors)

func give_reward(main: Main) -> void:
	reward.give.call(main)

func _init(quest_reward: Reward, goal_list: Array) -> void:
	reward = quest_reward
	goals = goal_list

# List of quests
static var list: Array[Quest] = [
	# Quest 1
	Quest.new(
		Reward.new(
			"$3", 
			func(main: Main) -> void: main.money += 3
		),
		[]
	),
	
	# Quest 2
	Quest.new(
		Reward.new(
			"$3", 
			func(main: Main) -> void: main.money += 3
		),
		[]
	)
]

static func get_quest(index: int) -> Quest:
	if index >= 0 and index < list.size():
		return list[index]
	return null

