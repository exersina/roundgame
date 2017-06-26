function unittest.test_war()
	local function callwarsrv(cmd,request)
		return warmgr.dispatch(0,0,"cluster",cmd,request)
	end

	local function pack_skill(skill_type)
		return {
			type = skill_type,
		}
	end

	local function pack_hero(pid)
		local hero = {
			kind = "hero",
			pid = pid,
			gamesrv = "gamesrv_1",
			lv = 10,
			is_attacker = true,
			baseattrs = {
				hp = 10000,
				maxhp = 10000,
				mp = 10000,
				maxmp = 10000,
				sp = 100,
				atk = 10,
				defense = 10,
				kang = 0.1,
				bj = 0.1,
				mz = 0.6,
				ds = 0.2,
				lj = 0.3,
				ljcnt = 3,
				fire_fs_atk = 10,
				fire_fs_kang = 0.1,
				fire_fs_bj = 0.1,
				fire_fs_mz = 0.6,
				fire_fs_ds = 0.2,
				water_fs_atk = 10,
				water_fs_kang = 0.1,
				water_fs_bj = 0.1,
				water_fs_mz = 0.6,
				water_fs_ds = 0.2,
				ice_fs_atk = 10,
				ice_fs_kang = 0.1,
				ice_fs_bj = 0.1,
				ice_fs_mz = 0.6,
				ice_fs_ds = 0.2,
				poison_fs_atk = 10,
				poison_fs_kang = 0.1,
				poison_fs_bj = 0.1,
				poison_fs_mz = 0.6,
				poison_fs_ds = 0.2,
			},
			state = {},
			skills = {
			},
		}
		local bind_skills = {
			[1000001] = true,
			[1000002] = true,
			[1000003] = true,
		}
		for skill_type in pairs(bind_skills) do
			table.insert(hero.skills,pack_skill(skill_type))
		end
		local all_skills = {}
		for skill_type=1000001,1000022 do
			if not bind_skills[skill_type] then
				table.insert(all_skills,skill_type)
			end
		end
		shuffle(all_skills)
		all_skills = table.slice(all_skills,1,5)
		for i,skill_type in ipairs(all_skills) do
			table.insert(hero.skills,pack_skill(skill_type))
		end
		return hero
	end

	local function pack_war(warid,wartype)
		return {
			warid = warid,
			wartype = wartype,
			attackers = {
				pack_hero(1000001),
				pack_hero(1000002),
				pack_hero(1000003),
				pack_hero(1000004),
				pack_hero(1000005),
			},
			defensers = {
				pack_hero(1000006),
				pack_hero(1000007),
				pack_hero(1000008),
				pack_hero(1000009),
				pack_hero(1000010),
			},
		}
	end

	callwarsrv("startwar",{
		warid = warmgr.genid(),
		wartype = 0,
		attackers = {
		},
		defensers = {
		},
	})

	local num = 1
	for i=1,num do
		callwarsrv("startwar",pack_war(warmgr.genid(),0))
	end
end
