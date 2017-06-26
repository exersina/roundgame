##目标个数
	无
	单目标
	多目标

##目标
	none						无目标
	random_enemy_hero			随机敌方英雄
	all_enemy_hero				所有敌方英雄
	random_enemy_pet			随机敌方宠物
	all_enemy_pet				所有敌方宠物
	random_enemy				随机敌方
	all_enemy					所有敌方
	random_ally_hero			随机己方英雄
	all_ally_hero				所有己方英雄
	random_ally_pet				随机己方宠物
	all_ally_pet				所有己方宠物
	random_ally					随机己方
	all_ally					所有己方
	all							所有敌方/己方
	focus						焦点目标
	focus_around				焦点周围目标(周围9宫格,不包括焦点)
	focus_and_around			焦点周围目标(周围9宫格,包括焦点目标)
	focus_around2				焦点周围目标(周围前后左右,不包括焦点)
	focus_and_around2			焦点周围目标(周围前后左右,包括焦点)
	focus_left					焦点左侧(不包括焦点)
	focus_and_left				焦点左侧(包括焦点)
	focus_right					焦点右侧(不包括焦点)
	focus_and_right				焦点右侧(包括焦点)
	focus_left_right			焦点左右侧(不包括焦点)
	focus_and_left_right		焦点左右侧(包括焦点)
	focus_front					焦点前方(不包括焦点)
	focus_and_front				焦点前方(包括焦点)
	focus_back					焦点后方(不包括焦点)
	focus_and_back				焦点后方(包括焦点)
	focus_front_back			焦点前后方(不包括焦点)
	focus_and_front_back		焦点前后方(包括焦点)
	focus_row					焦点同排(不包括焦点)
	focus_and_row				焦点同排(包括焦点)
	focus_col					焦点同列(不包括焦点)
	focus_and_col				焦点同列(包括焦点)
	owner						技能拥有者(英雄/宠物/ai怪物)
	-- 以下单人目标和focus,均由周围,前后左右等表示
	caster						施法者自身
	master_hero					主人英雄
	master_pet					主人宠物

##施法效果
	1. 增减属性(如:add_hp/add_atk等)
	2. 增减buff
	3. 对于被动技能: 可能自带光环效果

##技能构成
	技能分为:主动技能+被动技能
	一个技能由若干效果构成,每条效果触发:改变属性/改变状态/增减buff/自带光环
