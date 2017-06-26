##战斗对象属性
	1. 基础属性
	hp							血量
	maxhp						血量上限
	mp							魔法
	maxmp						魔法上限
	sp							速度

	-- 物理属性
	atk							物理攻击力
	defense						物理防御力
	kang						物理吸收率/物理抗性
	bj							物理暴击率
	mz							物理命中率
	ds							物理躲闪率
	lj							物理连击率
	ljcnt						物理连击次数

	-- 法术属性可能分成多种类型,以下只用一种法术描述
	fire_fs_atk					火系法术攻击/火系法术伤害
	fire_fs_kang				火系法术抗性/火系法术吸收率
	fire_fs_bj					火系法术暴击
	fire_fs_mz					火系法术命中
	fire_fs_ds					火系法术躲闪
	water_fs_atk				水系法术攻击
	water_fs_kang				水系法术抗性
	water_fs_bj					水系法术暴击
	water_fs_mz					水系法术命中
	water_fs_ds					水系法术躲闪
	ice_fs_atk					冰系法术攻击
	ice_fs_kang					冰系法术抗性
	ice_fs_bj					冰系法术暴击
	ice_fs_mz					冰系法术命中
	ice_fs_ds					冰系法术躲闪
	poison_fs_atk				毒系法术攻击
	poison_fs_kang				毒系法术抗性
	poison_fs_bj				毒系法术暴击
	poison_fs_mz				毒系法术命中
	poison_fs_ds				毒系法术躲闪


	2. 加成类属性
	$attr_addn					$attr属性的加成
	$attr_deaddn				$attr属性的加成抑制
	一般而言,机率类属性没有加成属性，数值类属性有加成属性,如:
	atk_addn					物理伤害加成
	fire_fs_atk_addn			火系法术伤害加成
	hp_addn						治疗加成
	hp_deaddn					治疗抑制

##战斗对象状态
	defense				防御状态(xx%免伤)
	sleep				睡眠状态(只能使用药品)
	dizzy				眩晕状态(无法进行任何操作)
	chaos				混乱状态(任何攻击均转换成对随机目标进行普通物理攻击)
	fire				灼烧状态(进攻方使用火系法术时,暴击率+xx%,伤害+xx%)
	poison				中毒状态(每回合扣除xx毒伤害,持续xx回合)
	rage				狂暴状态(物理暴击率+xx%,物理伤害+xx%)
	freeze				冻结状态(免疫一切伤害,无法进行任何操作)
	sneak				潜行状态(无法被敌军看见,不会被aoe伤害,拥有者进行任何动作将取消潜行)


物理伤害计算公式:
	local damage = attacker.base.atk * (1 + attacker.atk_addn)
	if ishit(attacker.bj) then
		damage = 暴击计算公式
		-- e.g: damage = damage * attacker.bj_addn
	end
	local valid_damage = (damage - defenser.defense) * ( 1 - defenser.kang)
