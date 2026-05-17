local langs = {
	---------------
	--# ENGLISH #--
	---------------
	["en"] = {
		__name__ = "English", --name in game
		__code__ = "US", --Language code: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2

		--IN GAME SETTINGS
		s_tab_general = "General",
			s_logo_url_name = "Logo url",
			s_logo_url_hint = "Url for image. Recommended size - 400x85 pixels",
			s_logo_w_name = "Logo width",
			s_logo_h_name = "Logo height",
			s_subtitle_name = "Subtitle",
			s_subtitle_hint = "Available fields: {online}, {ping}, {time}, {nick}, {usergroup}",
			s_sizew_name = "Width",
			s_timeformat_name = "Time format",
			s_24h_format = "24 hours",
			s_12h_format = "12 hours",
			s_togglemode_name = "Toggle mode",
			s_togglemode_desc = "Scoreboard will remain open until you press TAB again",
			s_multiopen_name = "Multiple open",
			s_multiopen_desc = "Allows multiple windows to be open at once in player panels, instead of just one",
			s_mouseinteraction_name = "Effect interaction",
			s_mouseinteraction_desc = "Mouse interaction with background particles. ~5-10 fps cost",
			s_default_sort_name = "Default sort",
			s_sort_direction_name = "Sort direction",
			s_merge_jobs_name = "Merge jobs",
			s_merge_jobs_desc = "Merge jobs into categories",
			s_interval_name = "Interval",
			s_rounding_name = "Rounding",
			s_animate_name = "Animation",
			s_draw_blur_name = "Blur background",
			s_admin_mod_name = "Admin Mod",
			s_admin_mod_desc = "Select the admin mod that is installed on your server",
			s_effect_name = "Background effect",


		s_tab_ranks = "Ranks",
			s_rank_name = "Rank",
			s_rank_desc = "Add new usergroup rank configuration",
			s_rank_hint = "Enter the exact name of the user group / SteamID here",
			form_rank_draw = "Show",
			form_rank_name = "Displayed name",
			form_rank_color1 = "Rank color 1",
			form_rank_color2 = "Rank color 2",
			form_rank_glow = "Glow effect",
			form_rank_admin_cmds = "Admin commands",

		s_tab_columns = "Columns",
			s_columns_desc = "This is a column slot. If you set None, the slot is considered empty and is not displayed in the menu. Note that some columns will not work on other game modes.",
			col_none = "None",
			col_nickname = "Nickname",
			col_job = "Faction",
			col_role = "Role", -- "Job" column for TTT
			col_rank = "Rank",
			col_darkrpmoney = "Money",
			col_frags = "Kills",
			col_deaths = "Deaths",
			col_time = "Time",
			col_level = "Level",
			col_ttt_karma = "Karma",
			col_prestige = "Prestige",

		action_open_profile = "Open profile",
		action_unmute_cl = "Enable voice",
		action_mute_cl = "Disable voice",
		action_copy_profile = "Copy steam URL",
		action_goto = "Goto",
		action_bring = "Bring",
		action_return = "Return",
		action_freeze = "Freeze",
		action_unfreeze = "Unfreeze",
		action_copy_steamid = "Copy SteamID",
		action_copy_steamid64 = "Copy SteamID64",
		action_kick = "Kick",
		action_ban = "Ban",
		action_spectate = "Spectate",
		
		enter_duration = "Enter duration",
		enter_reason = "Enter reason",
		search_placeholder = "Nickname / SteamID",
		sort_ascending = "Ascending",
		sort_descending = "Descending",
		ping_postfix = "ms", --milliseconds
		copy_phrase = "Copy",
		--(DONT CHANGE %s - The value is added in place of %s) 
		--When a player has > 10000 money, the value is divided by 1000 and this format is used.
		money_format_k = "%sk", -- Money > 10.000
		money_format_m = "%sM",  -- Money > 1.000.000
		money_format_b = "%sB",  -- Money > 1.000.000.000
		you_format = "%s (You)",
		friend_format = "%s (Friend)",
		button_settings = "Open settings",
		button_search = "Search player",
		category_common = "Common",
		category_admin = "Admin",
		dots = "Dots", -- dots effect
		snow = "Snow",  -- snow effect
		none = "None",
	},

	---------------
	--# RUSSIAN #--
	---------------
	["ru"] = {
		__name__ = "Русский", --name in game
		__code__ = "RU", --Language code: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2

		--IN GAME SETTINGS
		s_tab_general = "Основные",
			s_logo_url_name = "Ссылка на лого",
			s_logo_url_hint = "Ссылка на картинку. Рекомендованный размер - 400x85 пикселей",
			s_logo_w_name = "Ширина лого",
			s_logo_h_name = "Высота лого",
			s_subtitle_name = "Подзаголовок",
			s_subtitle_hint = "Доступные поля: {online}, {ping}, {time}, {nick}, {usergroup}",
			s_sizew_name = "Ширина",
			s_timeformat_name = "Формат времени",
			s_24h_format = "24-х часовой формат",
			s_12h_format = "12-и часовой формат",
			s_togglemode_name = "Переключаемый режим",
			s_togglemode_desc = "Панель будет открыта до тех пор, пока вы снова не нажмёте клавишу TAB",
			s_multiopen_name = "Несколько открытых",
			s_multiopen_desc = "Позволяет открывать сразу несколько окон у игроков, а не только одно",
			s_mouseinteraction_name = "Взаимодействие с эффектом",
			s_mouseinteraction_desc = "Взаимодействие мыши с эффектом на заднем плане. ~5-10 fps",
			s_default_sort_name = "Сортировка по умолчанию",
			s_sort_direction_name = "Направление сортировки",
			s_merge_jobs_name = "Объединять работы",
			s_merge_jobs_desc = "Объединять работы в категории",
			s_interval_name = "Интервал",
			s_rounding_name = "Закругление",
			s_animate_name = "Анимация",
			s_draw_blur_name = "Размытие фона",
			s_admin_mod_name = "Админ мод",
			s_admin_mod_desc = "Выберите админ мод, который установлен на вашем сервере",
			s_effect_name = "Эффект частиц",

		s_tab_ranks = "Ранги",
			s_rank_name = "Ранг",
			s_rank_desc = "Добавьте конфигурацию для нового ранга",
			s_rank_hint = "Введите точное название ранга / SteamID",
			form_rank_draw = "Показывать",
			form_rank_name = "Отображаемое имя",
			form_rank_color1 = "Цвет ранга 1",
			form_rank_color2 = "Цвет ранга 2",
			form_rank_glow = "Эффект свечения",
			form_rank_admin_cmds = "Админ команды",

		s_tab_columns = "Столбцы",
			s_columns_desc = "Это слот для столбца. Если вы выставляете Пусто, то слот считается пустым и не отображается в меню. Учитывайте, что некоторые столбцы не будут работать на других игровых режимах.",
			col_none = "Пусто",
			col_nickname = "Никнейм",
			col_job = "Работа",
			col_role = "Role", -- "Job" column for TTT
			col_rank = "Ранк",
			col_darkrpmoney = "Деньги",
			col_frags = "Убийства",
			col_deaths = "Смерти",
			col_time = "Время",
			col_level = "Уровень",
			col_ttt_karma = "Карма",
			col_prestige = "Престиж",

		action_open_profile = "Профиль",
		action_unmute_cl = "Звук вкл",
		action_mute_cl = "Звук выкл",
		action_copy_profile = "Профиль url",
		action_goto = "Телепорт",
		action_bring = "Тп к себе",
		action_return = "Вернуть",
		action_freeze = "Заморозить",
		action_unfreeze = "Разморозить",
		action_copy_steamid = "Скопировать SteamID",
		action_copy_steamid64 = "Скопировать SteamID64",
		action_kick = "Кик",
		action_ban = "Бан",
		action_spectate = "Следить",
		
		enter_duration = "Введите длительность",
		enter_reason = "Введите причину",
		search_placeholder = "Никнейм / SteamID",
		sort_ascending = "По возрастанию",
		sort_descending = "По убыванию",
		ping_postfix = "мс",
		copy_phrase = "Скопировать",
		--(DONT CHANGE %s - The value of money is added in place of %s) 
		--When a player has > 10000 money, the value is divided by 1000 and this format is used.
		money_format_k = "%s тыс", -- Money > 10.000
		money_format_m = "%s млн",  -- Money > 1.000.000
		money_format_b = "%s млрд",  -- Money > 1.000.000.000
		you_format = "%s (Вы)",
		friend_format = "%s (Друг)",
		button_settings = "Открыть настройки",
		button_search = "Поиск игрока",
		category_common = "Главное",
		category_admin = "Администратор",
		dots = "Точки", -- dots effect
		snow = "Снег",  -- snow effect
		none = "Ничего",
	},

	---------------
	--# TURKISH #--
	---------------
	--by https://www.gmodstore.com/users/ShaZzam
	["tr"] = {
		__name__ = "Türkçe", --oyundaki isim
		__code__ = "TR", --Dil kodu: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2

		--OYUN İÇİ AYARLAR
		s_tab_general = "Genel",
			s_logo_url_name = "Logo URL'si",
			s_logo_url_hint = "Resim URL'si. Önerilen boyut - 400x85 piksel",
			s_logo_w_name = "Logo genişliği",
			s_logo_h_name = "Logo yüksekliği",
			s_subtitle_name = "Alt başlık",
			s_subtitle_hint = "Kullanılabilir alanlar: {online}, {ping}, {time}, {nick}, {usergroup}",
			s_sizew_name = "Genişlik",
			s_timeformat_name = "Zaman formatı",
			s_24h_format = "24 saat",
			s_12h_format = "12 saat",
			s_togglemode_name = "Geçiş modu",
			s_togglemode_desc = "Skorbord, TAB tuşuna tekrar basana kadar açık kalır",
			s_multiopen_name = "Çoklu açma",
			s_multiopen_desc = "Oyuncu panellerinde birden fazla pencerenin aynı anda açık olmasına izin verir",
			s_mouseinteraction_name = "Efekt etkileşimi",
			s_mouseinteraction_desc = "Arka plan parçacıkları ile fare etkileşimi. ~5-10 fps maliyeti",
			s_default_sort_name = "Varsayılan sıralama",
			s_sort_direction_name = "Sıralama yönü",
			s_merge_jobs_name = "İşleri birleştir",
			s_merge_jobs_desc = "İşleri kategorilere birleştir",
			s_interval_name = "Aralık",
			s_rounding_name = "Yuvarlama",
			s_animate_name = "Animasyon",
			s_draw_blur_name = "Arka plan bulanıklığı",
			s_admin_mod_name = "Admin Modu",
			s_admin_mod_desc = "Sunucunuzda yüklü olan admin modunu seçin",
			s_effect_name = "Arka plan efekti",


		s_tab_ranks = "Rütbeler",
			s_rank_name = "Rütbe",
			s_rank_desc = "Yeni kullanıcı grubu rütbesi yapılandırması ekle",
			s_rank_hint = "Kullanıcı grubunun veya SteamID'nin tam adını buraya girin",
			form_rank_draw = "Göster",
			form_rank_name = "Görünen isim",
			form_rank_color1 = "Rütbe rengi 1",
			form_rank_color2 = "Rütbe rengi 2",
			form_rank_glow = "Parlama efekti",
			form_rank_admin_cmds = "Admin komutları",

		s_tab_columns = "Sütunlar",
			s_columns_desc = "Bu bir sütun slotudur. 'Hiçbiri' olarak ayarlarsınız, slot boş olarak kabul edilir ve menüde görüntülenmez. Bazı sütunlar diğer oyun modlarında çalışmaz.",
			col_none = "Hiçbiri",
			col_nickname = "Takma ad",
			col_job = "İş",
			col_role = "Role", -- "Job" column for TTT
			col_rank = "Rütbe",
			col_darkrpmoney = "Para",
			col_frags = "Öldürme",
			col_deaths = "Ölüm",
			col_time = "Zaman",
			col_level = "Seviye",
			col_ttt_karma = "Karma",
			col_prestige = "Prestiges",

		action_open_profile = "Profili aç",
		action_unmute_cl = "Sesi etkinleştir",
		action_mute_cl = "Sesi devre dışı bırak",
		action_copy_profile = "Steam URL'sini kopyala",
		action_goto = "Git",
		action_bring = "Getir",
		action_return = "Geri dön",
		action_freeze = "Dondur",
		action_unfreeze = "Çöz",
		action_copy_steamid = "SteamID'yi kopyala",
		action_copy_steamid64 = "SteamID64'ü kopyala",
		action_kick = "Kick",
		action_ban = "Ban",
		action_spectate = "Spectate",
		
		enter_duration = "Enter duration",
		enter_reason = "Enter reason",
		search_placeholder = "Takma ad / SteamID",
		sort_ascending = "Artan",
		sort_descending = "Azalan",
		ping_postfix = "ms", --milisaniye
		copy_phrase = "Kopyala",
		--(%s'i DEĞİŞİM - Değer %s yerine eklenir)
		--Bir oyuncunun parası > 10000 olduğunda, değer 1000'e bölünür ve bu format kullanılır.
		money_format_k = "%sk", -- Money > 10.000
		money_format_m = "%sM",  -- Money > 1.000.000
		money_format_b = "%sB",  -- Money > 1.000.000.000
		you_format = "%s (Sen)",
		friend_format = "%s (Arkadaş)",
		button_settings = "Ayarları aç",
		button_search = "Oyuncu ara",
		category_common = "Genel",
		category_admin = "Admin",
		dots = "Nokta", -- nokta efekti
		snow = "Kar",  -- kar efekti
		none = "Hiçbiri",
	},

	---------------
	--# French #--
	---------------
	--by https://www.gmodstore.com/users/00000000000000000
	["fr"] = {
		__name__ = "French", --name in game
		__code__ = "FR", --Language code: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2

		--IN GAME SETTINGS
		s_tab_general = "Général",
			s_logo_url_name = "Lien logo",
			s_logo_url_hint = "Lien de l'image. Taille recommandée - 400x85 pixels",
			s_logo_w_name = "Largeur logo",
			s_logo_h_name = "Hauteur logo",
			s_subtitle_name = "Sous-titre",
			s_subtitle_hint = "Champs disponible: {online}, {ping}, {time}, {nick}, {usergroup}",
			s_sizew_name = "Largeur",
			s_timeformat_name = "Format du temps",
			s_24h_format = "24 heures",
			s_12h_format = "12 heures",
			s_togglemode_name = "Mode actif",
			s_togglemode_desc = "Le panneau restera ouvert jusqu'à ce que vous appuyiez à nouveau sur la touche TAB",
			s_multiopen_name = "Ouverture multiple",
			s_multiopen_desc = "Autoriser l'ouverture de plusieurs fenêtres de joueurs en même temps,au lieu d'une seule",
			s_mouseinteraction_name = "Effect d'interaction",
			s_mouseinteraction_desc = "Interaction de la souris avec l'effet de fond. Perte de ~5-10 fps",
			s_default_sort_name = "Tri par défaut",
			s_sort_direction_name = "Direction de tri",
			s_merge_jobs_name = "Fusionner les emplois",
			s_merge_jobs_desc = "Fusionner les emplois dans les catégories",
			s_interval_name = "Intervale",
			s_rounding_name = "Arrondi",
			s_animate_name = "Animation",
			s_draw_blur_name = "Font flou",
			s_admin_mod_name = "Mode Admin",
			s_admin_mod_desc = "Choisissez le mode admin installé sur votre serveur",
			s_effect_name = "Effet de fond",


		s_tab_ranks = "Rangs",
			s_rank_name = "Rangs",
			s_rank_desc = "Ajouter une configuration pour un nouveau rang",
			s_rank_hint = "Entrer le nom exact du rang / SteamID",
			form_rank_draw = "Afficher",
			form_rank_name = "Nom affiché",
			form_rank_color1 = "Couleur rang 1",
			form_rank_color2 = "Couleur rang 2",
			form_rank_glow = "Effet lumineux",
			form_rank_admin_cmds = "Commandes Admin",

		s_tab_columns = "Colonnes",
			s_columns_desc = "Ceci est un emplacement pour une colonne. Si vous définissez Vide, l'emplacement est considéré comme vide et n'apparaît pas dans le menu. Notez que certaines colonnes ne fonctionneront pas sur d'autres modes de jeu.",
			col_none = "Vide",
			col_nickname = "Pseudo",
			col_job = "Faction",
			col_role = "Role", -- "Job" column for TTT
			col_rank = "Rang",
			col_darkrpmoney = "Argent",
			col_frags = "Tués",
			col_deaths = "Morts",
			col_time = "Temps",
			col_level = "Niveau",
			col_ttt_karma = "Karma",
			col_prestige = "Prestiges",

		action_open_profile = "Ouvrir le profil",
		action_unmute_cl = "Activer la voix",
		action_mute_cl = "Désactiver la voix",
		action_copy_profile = "Copier le profil",
		action_goto = "Aller",
		action_bring = "Amener",
		action_return = "Retourner",
		action_freeze = "Geler",
		action_unfreeze = "Dégeler",
		action_copy_steamid = "Copier SteamID",
		action_copy_steamid64 = "Copier SteamID64",
		action_kick = "Kick",
		action_ban = "Ban",
		action_spectate = "Spectate",
		
		enter_duration = "Enter duration",
		enter_reason = "Enter reason",
		search_placeholder = "Pseudo / SteamID",
		sort_ascending = "Ascendant",
		sort_descending = "Descendant",
		ping_postfix = "ms", --milliseconds
		copy_phrase = "Copier",
		--(DONT CHANGE %s - The value is added in place of %s) 
		--When a player has > 10000 money, the value is divided by 1000 and this format is used.
		money_format_k = "%sk", -- Money > 10.000
		money_format_m = "%sM",  -- Money > 1.000.000
		money_format_b = "%sB",  -- Money > 1.000.000.000
		you_format = "%s (Vous)",
		friend_format = "%s (Ami)",
		button_settings = "Ouvrir les paramètres",
		button_search = "Chercher un joueur",
		category_common = "Commun",
		category_admin = "Admin",
		dots = "Points", -- dots effect
		snow = "Neige",  -- snow effect
		none = "Aucun",
	},

	--------------
	--# GERMAN #--
	--------------
	--by https://www.gmodstore.com/users/lumamarius
	["de"] = {
		__name__ = "German", --name in game
		__code__ = "DE", --Language code: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2

		--IN GAME SETTINGS
		s_tab_general = "Allgemein",
			s_logo_url_name = "Link vom Logo",
			s_logo_url_hint = "Der Link von deinem Logo, Empfohlene Größe - 400x85 Pixel",
			s_logo_w_name = "Breite des Logos",
			s_logo_h_name = "Höhe des Logos",
			s_subtitle_name = "Untertitel",
			s_subtitle_hint = "Verfügbare Felder: {online}, {ping}, {time}, {nick}, {usergroup}",
			s_sizew_name = "Breite",
			s_timeformat_name = "Zeitformat",
			s_24h_format = "24 Stunden",
			s_12h_format = "12 Stunden",
			s_togglemode_name = "Modus umschalten",
			s_togglemode_desc = "Das Scoreboard bleibt geöffnet, bis du wieder TAB drückst.",
			s_multiopen_name = "Mehrere Fenster",
			s_multiopen_desc = "Ermöglicht das Öffnen mehrerer Fenster im Scoreboard.",
			s_mouseinteraction_name = "Effekt Interaktion",
			s_mouseinteraction_desc = "Maus-Interaktion mit den Hintergrundpartikeln. Verbraucht ungefähr 5-10 FPS.",
			s_default_sort_name = "Standard Sortierung",
			s_sort_direction_name = "Sortierung",
			s_merge_jobs_name = "Berufe zusammenfügen",
			s_merge_jobs_desc = "Füge Berufe in Kategorien zusammen.",
			s_interval_name = "Interval",
			s_rounding_name = "Rundung",
			s_animate_name = "Animation",
			s_draw_blur_name = "Hintergrund verwischen",
			s_admin_mod_name = "Administrationssystem",
			s_admin_mod_desc = "Wähle das System, welches auf deinem Server installiert ist.",
			s_effect_name = "Hintergrundeffekt",


		s_tab_ranks = "Ränge",
			s_rank_name = "Rang",
			s_rank_desc = "Füge eine neue Usergroup zum Scoreboard hinzu.",
			s_rank_hint = "Schreibe den EXAKTEN Namen der Usergroup / SteamID hier rein.",
			form_rank_draw = "Anzeigen",
			form_rank_name = "Anzeigename",
			form_rank_color1 = "Rangfarbe 1",
			form_rank_color2 = "Rangfarbe 2",
			form_rank_glow = "Leuchteffekt",
			form_rank_admin_cmds = "Adminbefehle",

		s_tab_columns = "Spalten",
			s_columns_desc = "Dies ist ein Spaltenplatz. Wenn du 'Keine' einstellst, gilt der Slot als leer und wird nicht im Menü angezeigt. Beachte, dass einige Spalten in anderen Spielmodi nicht funktionieren.",
			col_none = "Keine",
			col_nickname = "Nickname",
			col_job = "Faction",
			col_role = "Role", -- "Job" column for TTT
			col_rank = "Rang",
			col_darkrpmoney = "Geld",
			col_frags = "Kills",
			col_deaths = "Tode",
			col_time = "Spielzeit",
			col_level = "Level",
			col_ttt_karma = "Karma",
			col_prestige = "Prestiges",

		action_open_profile = "Profil öffnen",
		action_unmute_cl = "Unmuten",
		action_mute_cl = "Muten",
		action_copy_profile = "Steam Link kopieren",
		action_goto = "Goto",
		action_bring = "Bring",
		action_return = "Return",
		action_freeze = "Freeze",
		action_unfreeze = "Unfreeze",
		action_copy_steamid = "SteamID kopieren",
		action_copy_steamid64 = "SteamID64 kopieren",
		action_kick = "Kick",
		action_ban = "Ban",
		action_spectate = "Spectate",
		
		enter_duration = "Enter duration",
		enter_reason = "Enter reason",
		search_placeholder = "Nickname / SteamID",
		sort_ascending = "Aufsteigend",
		sort_descending = "Absteigend",
		ping_postfix = "ms", --milliseconds
		copy_phrase = "Kopieren",
		--(DONT CHANGE %s - The value is added in place of %s) 
		--When a player has > 10000 money, the value is divided by 1000 and this format is used.
		money_format_k = "%sk", -- Money > 10.000
		money_format_m = "%sM",  -- Money > 1.000.000
		money_format_b = "%sB",  -- Money > 1.000.000.000
		you_format = "%s (Du)",
		friend_format = "%s (Freund)",
		button_settings = "Einstellungen öffnen",
		button_search = "Spieler suchen",
		category_common = "Allgemein",
		category_admin = "Admin",
		dots = "Punkte",  -- dots effect
		snow = "Schnee",  -- snow effect
		none = "Keiner",  -- None effect
	},

	--------------
	--# POLISH #--
	--------------
	--by https://www.gmodstore.com/users/nafik
	["pl"] = {
        __name__ = "Polish", --name in game
        __code__ = "PL", --Language code: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2

        --IN GAME SETTINGS
        s_tab_general = "Generalne",
        s_logo_url_name = "URL loga",
        s_logo_url_hint = "Adres URL loga. Zalecany rozmiar - 400x85 px",
            s_logo_w_name = "Szerokość logo",
            s_logo_h_name = "Wysokość logo",
            s_subtitle_name = "Podtytuł",
            s_subtitle_hint = "Dostępne pola: {online}, {ping}, {time}, {nick}, {usergroup}",
            s_sizew_name = "Szerokość",
            s_timeformat_name = "Format czasu",
            s_24h_format = "24 godzinowy",
            s_12h_format = "12 godzinowy",
            s_togglemode_name = "Przełącz tryb",
            s_togglemode_desc = "Tablica pozostanie otwarta do momentu ponownego naciśnięcia klawisza TAB",
            s_multiopen_name = "Wielokrotne otwarcie",
            s_multiopen_desc = "Umożliwia jednoczesne otwieranie wielu okien, zamiast tylko jednego",
            s_mouseinteraction_name = "Interakcja z efektem",
            s_mouseinteraction_desc = "Interakcja myszy z efektem w tle. ~5-10 fps",
            s_default_sort_name = "Domyślne sortowanie",
            s_sort_direction_name = "Kierunek sortowania",
            s_merge_jobs_name = "Łączenie prac",
            s_merge_jobs_desc = "Łączenie graczy w kategorie, bazując na pracy",
            s_interval_name = "Interwał",
            s_rounding_name = "Zaokrąglenie",
            s_animate_name = "Animacja",
            s_draw_blur_name = "Rozmycie tła",
            s_admin_mod_name = "Admin mod",
            s_admin_mod_desc = "Wybierz Admin mod'a, który jest zainstalowany na serwerze",
            s_effect_name = "Efekt cząsteczkowy",


        s_tab_ranks = "Rangi",
            s_rank_name = "Ranga",
            s_rank_desc = "Dodaj nową konfigurację rangi grupy użytkowników",
            s_rank_hint = "Wprowadź tutaj dokładną nazwę grupy",
            form_rank_draw = "Pokaż",
            form_rank_name = "Wyświetlana nazwa",
            form_rank_color1 = "Kolor rangi 1",
            form_rank_color2 = "Kolor rangi 2",
            form_rank_glow = "Efekt świetlny",
            form_rank_admin_cmds = "Komendy admina",

        s_tab_columns = "Kolumny",
            s_columns_desc = "To jest slot kolumny. Jeśli ustawisz Nic, slot jest uważany za pusty i nie jest wyświetlany w menu. Należy pamiętać, że niektóre kolumny nie będą działać w innych trybach gry.",
            col_none = "Nic",
            col_nickname = "Nazwa",
            col_job = "Faction",
			col_role = "Role", -- "Job" column for TTT
            col_rank = "Ranga",
            col_darkrpmoney = "Pieniądze",
            col_frags = "Zabójstwa",
            col_deaths = "Śmierci",
            col_time = "Czas",
            col_level = "Poziom",
			col_ttt_karma = "Karma",
			col_prestige = "Prestiges",

        action_open_profile = "Profil",
        action_unmute_cl = "Włącz głos",
        action_mute_cl = "Wyłącz głos",
        action_copy_profile = "URL profilu",
        action_goto = "Goto",
        action_bring = "Bring",
        action_return = "Return",
        action_freeze = "Freeze",
        action_unfreeze = "Unfreeze",
        action_copy_steamid = "Kopiuj SteamID",
        action_copy_steamid64 = "Kopiuj SteamID64",
		action_kick = "Kick",
		action_ban = "Ban",
		action_spectate = "Spectate",
		
		enter_duration = "Enter duration",
		enter_reason = "Enter reason",
        search_placeholder = "Nazwa / SteamID",
        sort_ascending = "Rosnąco",
        sort_descending = "Malejąco",
        ping_postfix = "ms", --milliseconds
        copy_phrase = "Kopiuj",
        --(DONT CHANGE %s - The value is added in place of %s) 
        --When a player has > 10000 money, the value is divided by 1000 and this format is used.
        money_format_k = "%sk", -- Money > 10.000
		money_format_m = "%sM",  -- Money > 1.000.000
		money_format_b = "%sB",  -- Money > 1.000.000.000
        you_format = "%s (Ty)",
        friend_format = "%s (Znajomy)",
        button_settings = "Otowórz ustawienia",
        button_search = "Wyszukaj gracza",
        category_common = "Ogólne",
        category_admin = "Administracyjne",
        dots = "Dots", -- dots effect
        snow = "Snow",  -- snow effect
        none = "None", 
	},

}

escore2.addon:RegisterLanguages(langs)

-- if GetConVar("gmod_language") not in languages table, sets this language
escore2.addon:SetDefaultLanguage("en")


--Dont edit this
if IsValid(escore2.bg) then --lua refresh
    escore2:Build()
end