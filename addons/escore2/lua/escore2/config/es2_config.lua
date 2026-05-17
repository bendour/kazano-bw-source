local cfg = escore2.config --Dont change that

--You can change theese values in game
cfg.size_width = 0.8
cfg.default_logo_url = "https://i.imgur.com/mFe56Qf.png"
cfg.logo_w = 400
cfg.logo_h = 85
cfg.interval = 3
cfg.rounding = 8
cfg.toggle_mode = false
cfg.multiopen = false
cfg.mouse_interaction = true
cfg.merge_jobs = false
cfg.animate = true
cfg.blur = true
cfg.enable_effect = true

--Currently supported: "sam", "ulx", "fadmin"
cfg.admin_mod = "sam"

--Currently supported: "dots", "snow", "none"
cfg.effect = "dots"

--Available {online}, {ping}, {time} formats here
cfg.default_subtitle = "Online {online} • Ping {ping} • Time {time}"