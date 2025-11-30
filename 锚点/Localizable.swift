import Foundation

struct L10n {
    // MARK: - Common
    static let appName = isUSVersion ? "Lumea" : "澄域"
    static let cancel = isUSVersion ? "Cancel" : "取消"
    static let confirm = isUSVersion ? "Confirm" : "确认"
    static let done = isUSVersion ? "Done" : "完成"
    static let save = isUSVersion ? "Save" : "保存"
    static let delete = isUSVersion ? "Delete" : "删除"
    static let back = isUSVersion ? "Back" : "返回"
    
    // MARK: - Tab Bar
    static let tabCalm = isUSVersion ? "Calm" : "澄域"
    static let tabStatus = isUSVersion ? "Status" : "状态"
    static let tabRehab = isUSVersion ? "Rehab" : "戒断"
    static let tabProfile = isUSVersion ? "Profile" : "我的"
    
    // MARK: - Login
    static let loginTitle = isUSVersion ? "Welcome to Lumea" : "欢迎来到澄域"
    static let loginSubtitle = isUSVersion ? "Find your inner peace" : "找到内心的平静"
    static let signInWithApple = isUSVersion ? "Sign in with Apple" : "使用 Apple 登录"
    static let signInWithGoogle = isUSVersion ? "Sign in with Google" : "使用 Google 登录"
    static let skipLogin = isUSVersion ? "Skip for now" : "暂时跳过"
    
    // MARK: - Onboarding
    static let onboardingWelcome = isUSVersion ? "Welcome" : "欢迎"
    static let onboardingTitle1 = isUSVersion ? "Visualize Your Mind" : "可视化你的心智"
    static let onboardingDesc1 = isUSVersion ? "Watch your mental state reflected in a fluid sphere" : "观察流体光球反映你的心智状态"
    static let onboardingTitle2 = isUSVersion ? "Build Stability" : "建立稳定"
    static let onboardingDesc2 = isUSVersion ? "Practice mindfulness daily to increase your stability score" : "每日正念练习，提升稳定值"
    static let onboardingTitle3 = isUSVersion ? "Track Cognitive Load" : "追踪认知负荷"
    static let onboardingDesc3 = isUSVersion ? "Monitor screen time impact on your mental health" : "监测屏幕使用对心理健康的影响"
    static let getStarted = isUSVersion ? "Get Started" : "开始使用"
    static let next = isUSVersion ? "Next" : "下一步"
    
    // Onboarding Scenes
    static let onboardingScene1 = isUSVersion ? 
        "In the digital age,\nmost people are trapped in short-video addiction.\n\nResearch from leading psychology journals confirms:\nThis triggers anxiety, depression,\nleading to loss of patience and decline in deep thinking." :
        "数字时代，\n多数人深陷短视频成瘾困局。\n\n权威心理学期刊研究证实：\n这会引发焦虑、抑郁，\n导致耐心流失、深度思考能力衰退。"
    
    static let onboardingScene2 = isUSVersion ?
        "This app is built to be 'anti-instinct'.\n\nIt may feel uncomfortable,\neven lacking in 'user experience'.\n\nBut that's the point:\nTo fight against instinctive digital addiction,\nand rebuild your mental control." :
        "这款 App，为「反人性」而生。\n\n它或许让你感到不适，\n甚至觉得「缺乏体验感」。\n\n但这正是它的初衷：\n对抗本能的数字沉迷，\n重塑你的心智掌控力。"
    
    static let onboardingScene3Permission = isUSVersion ?
        "To protect your anchor,\nwe need to monitor apps that steal your attention.\n\nPlease grant 'Screen Time' permission,\nso we can help you resist the digital flood." :
        "为了保护你的锚点，\n我们需要监测那些试图夺走你注意力的应用。\n\n请授权「使用情况访问权限」，\n让我们为你抵御数字洪流。"
    
    static let onboardingScene3 = isUSVersion ?
        "Overcome this discomfort,\nand you will regain:\n\nPatience,\nDeep thinking ability,\nInner peace." :
        "克服这些不适，\n你将重新拥有：\n\n耐心、\n深度思考的能力、\n内心的平静。"
    
    static let onboardingSource = isUSVersion ?
        "Source: Psychological Bulletin 2025. Attention r=-.38, Inhibitory Control r=-.41." :
        "Source: Psychological Bulletin 2025. Attention r=-.38, Inhibitory Control r=-.41."
    
    static let grantAccess = isUSVersion ? "Grant Access" : "授权访问"
    static let letsBegin = isUSVersion ? "Let's Begin!" : "让我们开始吧！"
    
    // MARK: - Calm View (Main)
    static let stability = isUSVersion ? "Stability" : "稳定值"
    static let cognitiveLoad = isUSVersion ? "Cognitive Load" : "认知负荷"
    static let startMeditation = isUSVersion ? "Start Meditation" : "开始冥想"
    static let touchAnchor = isUSVersion ? "Touch Anchor" : "触感锚点"
    static let flowReading = isUSVersion ? "Flow Reading" : "心流铸核"
    static let emotionRelease = isUSVersion ? "Emotion Release" : "情绪光解"
    
    // MARK: - Meditation
    static let meditationTitle = isUSVersion ? "Meditation" : "冥想"
    static let selectDuration = isUSVersion ? "Select Duration" : "选择时长"
    static let selectMusic = isUSVersion ? "Select Music" : "选择音乐"
    static let minutes = isUSVersion ? "min" : "分钟"
    static let start = isUSVersion ? "Start" : "开始"
    static let pause = isUSVersion ? "Pause" : "暂停"
    static let resume = isUSVersion ? "Resume" : "继续"
    static let finish = isUSVersion ? "Finish" : "完成"
    
    // MARK: - Music
    static let musicRelax = isUSVersion ? "Relax" : "放松"
    static let musicMorning = isUSVersion ? "Morning" : "清晨"
    static let musicSoul = isUSVersion ? "Soul" : "灵魂"
    static let musicEthereal = isUSVersion ? "Ethereal" : "空灵"
    static let musicClassical = isUSVersion ? "Classical" : "现代古典"
    static let musicSoothing = isUSVersion ? "Soothing" : "舒缓"
    static let musicBeat = isUSVersion ? "Beat" : "节拍"
    static let musicRain = isUSVersion ? "Rain" : "轻雨"
    static let premiumMusic = isUSVersion ? "Premium Music" : "会员音乐"
    
    // Premium Music
    static let musicAtmosphere = isUSVersion ? "Atmosphere" : "氛围"
    static let musicCalm = isUSVersion ? "Calm" : "冷静"
    static let musicTranquil = isUSVersion ? "Tranquil" : "宁静"
    static let musicPleasant = isUSVersion ? "Pleasant" : "惬意"
    static let musicForest = isUSVersion ? "Forest" : "森林"
    static let musicValley = isUSVersion ? "Valley" : "山谷"
    static let musicSunshine = isUSVersion ? "Sunshine" : "阳光"
    static let musicHealing = isUSVersion ? "Healing" : "治愈"
    
    // MARK: - Status
    static let statusTitle = isUSVersion ? "Status" : "状态"
    static let stabilityScore = isUSVersion ? "Stability Score" : "稳定值"
    static let cognitiveLoadIndex = isUSVersion ? "Cognitive Load Index" : "认知负荷指数"
    static let todayPractice = isUSVersion ? "Today's Practice" : "今日练习"
    static let viewInsights = isUSVersion ? "View Insights" : "查看洞察"
    
    // MARK: - Profile
    static let profileTitle = isUSVersion ? "Profile" : "个人信息"
    static let myStats = isUSVersion ? "My Stats" : "我的统计"
    static let dailyReminder = isUSVersion ? "Daily Reminder" : "每日提醒"
    static let settings = isUSVersion ? "Settings" : "设置"
    static let helpFeedback = isUSVersion ? "Help & Feedback" : "帮助与反馈"
    static let subscription = isUSVersion ? "Subscription" : "订阅管理"
    static let logout = isUSVersion ? "Logout" : "退出登录"
    
    // MARK: - Settings
    static let settingsTitle = isUSVersion ? "Settings" : "设置"
    static let sphereMaterial = isUSVersion ? "Sphere Material" : "光球材质"
    static let soundEffects = isUSVersion ? "Sound Effects" : "音效"
    static let soundEffectsDesc = isUSVersion ? "Enable in-app sounds" : "开启应用内音效"
    static let hapticFeedback = isUSVersion ? "Haptic Feedback" : "触觉反馈"
    static let hapticFeedbackDesc = isUSVersion ? "Enable haptic feedback" : "开启触觉反馈"
    static let userAgreement = isUSVersion ? "Terms of Service" : "用户协议"
    static let privacyPolicy = isUSVersion ? "Privacy Policy" : "隐私政策"
    static let aboutApp = isUSVersion ? "About Lumea" : "关于澄域"
    static let version = isUSVersion ? "Version" : "版本"
    
    // MARK: - Subscription
    static let subscriptionTitle = isUSVersion ? "Lumea Premium" : "澄域会员"
    static let unlockPremium = isUSVersion ? "Unlock Premium Features" : "解锁会员功能"
    static let premiumFeature1 = isUSVersion ? "8 Premium Meditation Tracks" : "8 首会员专属冥想音乐"
    static let premiumFeature2 = isUSVersion ? "Advanced Sphere Materials" : "高级光球材质"
    static let premiumFeature3 = isUSVersion ? "Deep Insights & Analytics" : "深度洞察与分析"
    static let monthly = isUSVersion ? "Monthly" : "月度订阅"
    static let yearly = isUSVersion ? "Yearly" : "年度订阅"
    static let subscribe = isUSVersion ? "Subscribe" : "订阅"
    static let restorePurchase = isUSVersion ? "Restore Purchase" : "恢复购买"
    static let alreadySubscribed = isUSVersion ? "Already Subscribed" : "已订阅"
    static let manageSubscription = isUSVersion ? "Manage Subscription" : "管理订阅"
    
    // MARK: - Help & Feedback
    static let helpTitle = isUSVersion ? "Help & Feedback" : "帮助与反馈"
    static let faq = isUSVersion ? "FAQ" : "常见问题"
    static let feedback = isUSVersion ? "Feedback" : "反馈建议"
    static let contactUs = isUSVersion ? "Contact Us" : "联系我们"
    static let email = isUSVersion ? "Email" : "邮箱"
    static let submitFeedback = isUSVersion ? "Submit Feedback" : "提交反馈"
    
    // MARK: - Deep Insights
    static let deepInsightsTitle = isUSVersion ? "Deep Analysis" : "深度解析"
    static let weeklyReport = isUSVersion ? "Weekly Report" : "本周报告"
    static let monthlyReport = isUSVersion ? "Monthly Report" : "本月报告"
    static let practiceStreak = isUSVersion ? "Practice Streak" : "连续练习"
    static let days = isUSVersion ? "days" : "天"
    
    // Insight Tabs
    static let flowStability = isUSVersion ? "Flow Stability" : "心流稳定性"
    static let digitalRelation = isUSVersion ? "Digital Symbiosis" : "数字共生关系"
    static let meditationEcho = isUSVersion ? "Serenity Echo" : "宁静回响"
    
    // Insight Sections
    static let flowHeatmap = isUSVersion ? "Flow Fluctuation Heatmap" : "心流波动热力图"
    static let focusInterruption = isUSVersion ? "Focus Cycle Interruption Rate" : "专注周期中断率"
    static let flowRecoveryCurve = isUSVersion ? "Flow Recovery Curve" : "心流恢复曲线"
    static let hdaImpactDistribution = isUSVersion ? "Digital Distraction Distribution" : "数字分心分布"
    static let digitalDistractionHeatmap = isUSVersion ? "Digital Distraction Heatmap" : "数字分心热力图"
    static let meditationEffect = isUSVersion ? "Meditation Enhancement Effect" : "冥想提升效果"
    static let dataCollecting = isUSVersion ? "Collecting data..." : "数据收集中..."
    
    // Premium Lock
    static let flowTrajectoryPremium = isUSVersion ? "Flow Trajectory · Deep Insights Lumea PLUS Exclusive" : "心流轨迹 · 深度洞悉 澄域 PLUS 专享"
    static let upgradePremiumMessage = isUSVersion ? "Upgrade to Lumea PLUS to master inner order." : "升级静域 PLUS，掌握内在秩序。"
    
    // MyStatsView specific
    static let flowTrajectory = isUSVersion ? "Flow Trajectory · Deep Insight" : "心流轨迹 · 深度洞悉"
    static let premiumExclusiveSuffix = isUSVersion ? " Lumea PLUS Exclusive" : " 澄域 PLUS 专享"
    static let upgradeToMaster = isUSVersion ? "Upgrade to Lumea PLUS to master your inner order." : "升级静域 PLUS，掌握内在秩序。"
    static let digitalSymbiosis = isUSVersion ? "Digital Symbiosis" : "数字共生关系"
    static let digitalDistraction = isUSVersion ? "Digital Distraction Distribution" : "数字分心分布"
    static let serenityEcho = isUSVersion ? "Serenity Echo" : "宁静回响"
    
    // MARK: - Stats
    static let totalMeditation = isUSVersion ? "Total Meditation" : "累计冥想"
    static let totalPractices = isUSVersion ? "Total Practices" : "累计练习"
    static let averageStability = isUSVersion ? "Average Stability" : "平均稳定值"
    static let thisWeek = isUSVersion ? "This Week" : "本周"
    static let thisMonth = isUSVersion ? "This Month" : "本月"
    static let allTime = isUSVersion ? "All Time" : "全部"
    
    // MARK: - Daily Reminder
    static let dailyReminderTitle = isUSVersion ? "Daily Reminder" : "每日提醒"
    static let morning = isUSVersion ? "Morning" : "晨间"
    static let afternoon = isUSVersion ? "Afternoon" : "午后"
    static let evening = isUSVersion ? "Evening" : "傍晚"
    static let customTime = isUSVersion ? "Custom Time" : "自定义时间"
    static let addReminder = isUSVersion ? "Add Reminder" : "添加提醒"
    
    // MARK: - Serenity Guide
    static let guideStep0 = isUSVersion ?
        "This is your mind visualized.\n\nThis fluid light sphere\nreflects your stability.\n\nThe calmer you are,\nthe purer and more stable the sphere." :
        "这是你的心绪具象。\n\n这颗流体光影球体，\n反映着你的稳定值。\n\n越平静，\n光球越纯净、越稳定。"
    
    static let guideStep1 = isUSVersion ?
        "Touch Anchor: Fight impulse.\n\nWhen digital stimulation floods in,\nthe first thing you lose is self-control.\n\nThis practice helps you\nresist the urge to move,\nrebuilding the foundation of focus." :
        "触感锚点：对抗冲动。\n\n当数字刺激泛滥，\n你最先失去的是自控力。\n\n这个训练，旨在帮助你\n抑制\"想动\"的本能，\n重建专注的基石。"
    
    static let guideStep2 = isUSVersion ?
        "Flow Forging: Refine depth.\n\nFragmentation is destroying\nyour deep thinking ability.\n\nBy continuously forging chaotic particles,\ntrain yourself to maintain rhythm and focus\nin complex cognitive activities." :
        "心流铸核：提炼深度。\n\n碎片化正在破坏\n你的深度思考能力。\n\n通过持续熔炼混沌粒子，\n训练你在复杂的认知活动中，\n保持节奏和专注。"
    
    static let guideStep3 = isUSVersion ?
        "Emotion Photolysis: Release burden.\n\nAccumulated emotions are the source of mental drain.\n\nHere, we visualize your emotions\nas a 'shadow core',\nand witness it being dissolved by light,\nachieving complete psychological separation and release." :
        "情绪光解：卸下重负。\n\n积压的情绪是内耗的源头。\n\n在这里，我们将你的情绪\n具象化为\"阴影核心\"，\n并亲眼见证它被光解销毁，\n实现彻底的心理分离与释放。"
    
    static let guideStep4 = isUSVersion ?
        "Action brings peace.\n\nYour practice\nbegins with this moment of focus." :
        "行动，才有可能平静。\n\n你的修行，\n从此刻的专注开始。"
    
    static let tapToContinue = isUSVersion ? "Tap to continue" : "轻触继续"
    static let tapToBegin = isUSVersion ? "Tap to begin" : "轻触以开始"
    
    // MARK: - Touch Anchor
    static let touchAnchorTitle = isUSVersion ? "Touch Anchor" : "触感锚点"
    static let touchAnchorDesc = isUSVersion ? "Touch the sphere to ground yourself in the present moment" : "触摸光球，回到当下此刻"
    static let touchAnchorSubtitle = isUSVersion ? "Rebuild sensory connection" : "重塑感官连接"
    static let touchAnchorCompleted = isUSVersion ? "Mind anchored" : "心绪已归位"
    static let holdToConnect = isUSVersion ? "Hold to Connect" : "按住以连接"
    static let connected = isUSVersion ? "Connected" : "已连接"
    
    // MARK: - Flow Reading
    static let flowReadingTitle = isUSVersion ? "Flow Forging" : "心流铸核"
    static let flowReadingDesc = isUSVersion ? "Deep focus reading to rebuild attention" : "专注阅读，重建注意力"
    static let flowReadingSubtitle = isUSVersion ? "Mind-body unity" : "身心合一体验"
    static let flowReadingCompleted = isUSVersion ? "Flow forged" : "心流已铸就"
    static let enterText = isUSVersion ? "Enter your text here..." : "在此输入文字..."
    static let startReading = isUSVersion ? "Start Reading" : "开始阅读"
    static let focusTime = isUSVersion ? "Focus Time" : "专注时长"
    static let holdAndSlide = isUSVersion ? "Hold and slide to read line by line" : "按住并逐行滑动阅读"
    static let readingComplete = isUSVersion ? "Reading Complete" : "阅读完成"
    static let finishReading = isUSVersion ? "Finish Reading" : "完成阅读"
    
    static let flowReadingSample = isUSVersion ?
        """
        We often feel anxious, not because the future is truly frightening, but because we try to control things beyond our control.
        
        Stoicism teaches us that the only thing we can control is our judgment.
        
        When you feel stressed, ask yourself: Is this completely within my control? If not, accept that it happens.
        
        Focus on the present moment—it's the only remedy.
        
        (Continue sliding to read more...)
        
        True freedom is not doing whatever you want, but mastering your own mind.
        
        In this noisy world, silence is power.
        """ :
        """
        我们常常感到焦虑，不是因为未来真的有多可怕，而是因为我们试图控制那些不可控的事物。
        
        斯多葛学派告诉我们，唯一能控制的，是我们的判断。
        
        当你感到压力时，问自己：这件事完全在我的掌控之中吗？如果不是，那就接受它发生。
        
        专注当下，是唯一的解药。
        
        （继续滑动以阅读更多...）
        
        真正的自由，不是随心所欲，而是主宰自己的心智。
        
        在这个充满噪音的世界里，沉默是一种力量。
        """
    
    // MARK: - Mindful Reveal (Flow Forging)
    static let mindfulRevealTitle = isUSVersion ? "Flow Forging" : "心流铸核"
    static let mindfulRevealInstruction = isUSVersion ? "Hold screen and move to attract particles" : "按住屏幕，移动磁极吸附粒子"
    static let crystalComplete = isUSVersion ? "Stability Crystal · Forged" : "定静晶体 · 铸造完成"
    static let tapCrystal = isUSVersion ? "Tap crystal to merge with calm" : "轻触晶体，融入平静"
    
    // MARK: - Emotion Release
    static let emotionReleaseTitle = isUSVersion ? "Emotion Photolysis" : "情绪光解"
    static let emotionReleaseDesc = isUSVersion ? "Voice journal to process emotions" : "语音日记，释放情绪"
    static let emotionReleaseSubtitle = isUSVersion ? "Visualize & destroy emotions" : "具象化情绪销毁"
    static let emotionReleaseCompleted = isUSVersion ? "Emotions released" : "情绪已光释"
    static let tapToRecord = isUSVersion ? "Tap below to release emotions" : "点击下方，投递情绪"
    static let recording = isUSVersion ? "Recording..." : "录音中..."
    static let stopRecording = isUSVersion ? "Stop" : "停止"
    static let playback = isUSVersion ? "Playback" : "播放"
    static let nameThisCore = isUSVersion ? "Name this shadow core" : "为这个阴影核心命名"
    static let corePlaceholder = isUSVersion ? "e.g., Monday Anxiety" : "例如：周一焦虑"
    static let observeCore = isUSVersion ? "Observe it.\nThis is the burden you just released.\nIt doesn't define you." : "观察它。\n这是你刚刚卸下的重负。\n它不代表你。"
    static let startPhotolysis = isUSVersion ? "Start Photolysis" : "开始光解"
    static let photolyzing = isUSVersion ? "Photolyzing..." : "光解中..."
    static let returnToCalm = isUSVersion ? "Return to Calm" : "归于平静"
    
    // MARK: - HDA Settings
    static let hdaTitle = isUSVersion ? "High Dopamine Apps" : "高多巴胺应用"
    static let hdaDesc = isUSVersion ? "Monitor screen time impact" : "监测屏幕使用影响"
    static let hdaMonitoring = isUSVersion ? "High Dopamine App Monitoring" : "高多巴胺应用监测"
    static let hdaDescription = isUSVersion ? "Select apps to monitor. We'll quantify their impact on your cognitive resources." : "选择需要监测的应用，我们将量化它们对你认知资源的影响。"
    static let currentMonitorList = isUSVersion ? "Current Monitor List" : "当前监测列表"
    static let appsCount = isUSVersion ? "apps" : "个应用"
    static let noMonitoredApps = isUSVersion ? "No monitored apps" : "暂无监测应用"
    static let tapToAddApps = isUSVersion ? "Tap below to add apps" : "点击下方按钮添加应用"
    static let lastSync = isUSVersion ? "Last sync:" : "最后同步:"
    static let never = isUSVersion ? "Never" : "从未"
    static let addApp = isUSVersion ? "Add App" : "添加应用"
    static let removeApp = isUSVersion ? "Remove" : "移除"
    static let screenTimePermission = isUSVersion ? "Screen Time Permission Required" : "需要授权访问使用情况"
    static let screenTimePermissionDesc = isUSVersion ? "Please grant Lumea access to Screen Time in System Settings" : "请在系统设置中授予\"澄域\"访问使用情况的权限"
    static let grantPermission = isUSVersion ? "Grant Permission" : "授权访问"
    
    // MARK: - Material Picker
    static let materialPickerTitle = isUSVersion ? "Sphere Material" : "光球材质"
    static let selectMaterial = isUSVersion ? "Select a material for your sphere" : "选择光球的材质"
    static let materialDefault = isUSVersion ? "Default" : "默认"
    static let materialLava = isUSVersion ? "Lava" : "熔岩"
    static let materialIce = isUSVersion ? "Ice" : "寒冰"
    static let materialGold = isUSVersion ? "Gold" : "鎏金"
    static let materialAmber = isUSVersion ? "Amber" : "琥珀"
    static let materialNeon = isUSVersion ? "Neon" : "霓虹"
    static let materialNebula = isUSVersion ? "Nebula" : "星云"
    static let materialAurora = isUSVersion ? "Aurora" : "极光"
    static let materialSakura = isUSVersion ? "Sakura" : "樱花"
    static let materialOcean = isUSVersion ? "Ocean" : "深海"
    static let materialSunset = isUSVersion ? "Sunset" : "落日"
    static let materialForest = isUSVersion ? "Forest" : "森林"
    static let materialGalaxy = isUSVersion ? "Galaxy" : "星河"
    static let materialCrystal = isUSVersion ? "Crystal" : "水晶"
    
    // Material full names
    static let materialAmberFull = isUSVersion ? "Amber Light" : "琥珀之光"
    static let materialNeonFull = isUSVersion ? "Cyber Neon" : "赛博霓虹"
    static let materialNebulaFull = isUSVersion ? "Nebula Vortex" : "星云漩涡"
    static let materialAuroraFull = isUSVersion ? "Aurora Dream" : "极光幻境"
    static let materialSakuraFull = isUSVersion ? "Sakura Dream" : "樱花之梦"
    static let materialOceanFull = isUSVersion ? "Deep Ocean" : "深海秘境"
    static let materialSunsetFull = isUSVersion ? "Sunset Glow" : "落日余晖"
    static let materialForestFull = isUSVersion ? "Emerald Forest" : "翡翠森林"
    static let materialGalaxyFull = isUSVersion ? "Galaxy Journey" : "星河漫游"
    static let materialCrystalFull = isUSVersion ? "Crystal Spirit" : "水晶灵韵"
    
    static let premiumOnly = isUSVersion ? "Premium Only" : "仅限会员"
    static let previewMode = isUSVersion ? "Preview" : "预览中"
    static let unlock = isUSVersion ? "Unlock" : "解锁"
    static let flowVisualization = isUSVersion ? "Flow Visualization" : "心流具象"
    
    // MARK: - Alerts & Messages
    static let success = isUSVersion ? "Success" : "成功"
    static let error = isUSVersion ? "Error" : "错误"
    static let warning = isUSVersion ? "Warning" : "警告"
    static let sessionComplete = isUSVersion ? "Session Complete!" : "练习完成！"
    static let stabilityIncreased = isUSVersion ? "Stability increased by" : "稳定值增加"
    static let thankYou = isUSVersion ? "Thank you!" : "感谢！"
    static let feedbackReceived = isUSVersion ? "We've received your feedback" : "我们已收到你的反馈"
    
    // MARK: - Subscription Details
    static let subscriptionBenefit1 = isUSVersion ? "Premium meditation music collection" : "会员专属冥想音乐"
    static let subscriptionBenefit2 = isUSVersion ? "Exclusive sphere materials" : "独家光球材质"
    static let subscriptionBenefit3 = isUSVersion ? "Advanced analytics and insights" : "高级分析与洞察"
    static let subscriptionBenefit4 = isUSVersion ? "Priority support" : "优先客服支持"
    static let freeTrialAvailable = isUSVersion ? "7-day free trial" : "7 天免费试用"
    static let monthlyPrice = isUSVersion ? "$8.99/month" : "¥30/月"
    static let yearlyPrice = isUSVersion ? "$69.99/year" : "¥298/年"
    static let savePercent = isUSVersion ? "Save 33%" : "节省 33%"
    
    // MARK: - FAQ
    static let faqHowToStart = isUSVersion ? "How to start meditation?" : "如何开始冥想"
    static let faqWhatIsStability = isUSVersion ? "What is Stability Score?" : "什么是稳定值"
    static let faqWhatIsCLI = isUSVersion ? "What is Cognitive Load Index?" : "什么是认知负荷指数"
    static let faqHowToSetHDA = isUSVersion ? "How to set up HDA monitoring?" : "如何设置高多巴胺应用监测"
    static let faqFourPractices = isUSVersion ? "What are the four practices?" : "四个正念练习分别是什么"
    static let faqDailyReminder = isUSVersion ? "How to set daily reminders?" : "如何设置每日提醒"
    static let faqDataSync = isUSVersion ? "Will my data sync?" : "数据会同步吗"
    
    // MARK: - Feedback
    static let feedbackPlaceholder = isUSVersion ? "Share your experience, suggestions, or issues..." : "分享你的使用体验、建议或遇到的问题..."
    static let tellUsYourThoughts = isUSVersion ? "Tell us your thoughts" : "告诉我们你的想法"
    static let wechat = isUSVersion ? "WeChat" : "微信"
    
    // MARK: - Rehab
    static let rehabTitle = isUSVersion ? "Digital Detox" : "数字戒断"
    static let rehabDesc = isUSVersion ? "Break free from digital addiction" : "摆脱数字成瘾"
    static let startDetox = isUSVersion ? "Start Detox" : "开始戒断"
    static let detoxGoal = isUSVersion ? "Detox Goal" : "戒断目标"
    static let currentStreak = isUSVersion ? "Current Streak" : "当前连续"
    
    // MARK: - CalmView (Additional)
    static let tapSphereToMeditate = isUSVersion ? "Tap sphere to begin meditation" : "轻触光球，开始冥想"
    static let holdToExit = isUSVersion ? "Hold 2s to exit meditation" : "长按2秒退出冥想"
    static let completed = isUSVersion ? "Completed" : "完成"
    static let interrupted = isUSVersion ? "Interrupted" : "中断"
    static let avgDuration = isUSVersion ? "Avg Duration" : "平均时长"
    
    // MARK: - StatusView (Additional)
    static let unlockInsights = isUSVersion ? "Unlock Cognitive Insights" : "解锁认知洞察"
    static let authorizeToQuantify = isUSVersion ? "Authorize access to quantify digital stress" : "授权访问以量化数字压力"
    static let stabilityDynamics = isUSVersion ? "Stability Dynamics" : "稳定值动态"
    static let noRecords = isUSVersion ? "No records" : "暂无记录"
    static let completeTasksForStability = isUSVersion ? "Complete daily tasks to gain stability" : "完成每日任务以获得稳定值"
    static let warningLowStability = isUSVersion ? "Warning: Stability below 50%" : "警告：稳定值低于 50%"
    static let distractionTrajectory = isUSVersion ? "Distraction Trajectory" : "分心轨迹"
    static let goodFocusToday = isUSVersion ? "Good focus today" : "今日专注状况良好"
    static let sevenDayTrend = isUSVersion ? "7-Day Trend" : "7日趋势"
    static let loginAccount = isUSVersion ? "Login Account" : "登录账户"
    static let syncYourJourney = isUSVersion ? "Sync your meditation journey" : "同步你的冥想旅程"
    static let monitorList = isUSVersion ? "Monitor List" : "监测列表"
    static let within24h = isUSVersion ? "within 24h" : "24h 内"
    
    // MARK: - RehabView (Additional)
    static let selectTheme = isUSVersion ? "Select Background Theme" : "选择背景主题"
    
    // MARK: - SubscriptionAlertOverlay
    static let lumeaExclusive = isUSVersion ? "Lumea" : "澄域"
    static let plusExclusive = isUSVersion ? "PLUS" : "PLUS"
    static let exclusiveMusic = isUSVersion ? "Exclusive: " : " 专享："
    static let unlockSoundscape = isUSVersion ? "Unlock this deep soundscape to deepen your journey of mental order reconstruction." : "解锁此深度音景，深化您的心智秩序重塑之旅。"
    static let upgradeNow = isUSVersion ? "Upgrade to Lumea PLUS Now" : "立即升级澄域 PLUS"
    static let continueListening = isUSVersion ? "Continue Listening" : "继续试听"
    
    // MARK: - Login (New)
    static let appSlogan = isUSVersion ? "Light, Clarifying the Mind" : "以光，澄澈心灵"
    static let loginAgree = isUSVersion ? "By logging in, you agree to our" : "登录即代表同意"
    static let termsOfService = isUSVersion ? "Terms of Service" : "服务条款"
    static let and = isUSVersion ? "&" : "&"
    static let loginFailed = isUSVersion ? "Login Failed" : "登录失败"
    static let checkNetwork = isUSVersion ? "Login failed, please check your network connection" : "登录失败，请检查网络连接后重试"
    static let tryAgainLater = isUSVersion ? "Unable to complete login, please try again later" : "无法完成登录，请稍后重试"
    static let loginErrorPrefix = isUSVersion ? "Login failed: " : "登录失败："
    
    // MARK: - Status (New)
    static let statusExcellent = isUSVersion ? "Excellent" : "优秀"
    static let statusModerate = isUSVersion ? "Moderate" : "中等"
    static let statusAtRisk = isUSVersion ? "At Risk" : "危险"
    
    // CLI Status
    static let cliStatusCritical = isUSVersion ? "Severe Depletion" : "严重透支"
    static let cliStatusHigh = isUSVersion ? "High Load" : "高负荷"
    static let cliStatusModerate = isUSVersion ? "Attention Scattered" : "注意力分散"
    static let cliStatusGood = isUSVersion ? "Good State" : "状态良好"
    
    static let cliInfoTitle = isUSVersion ? "Cognitive Load Index (CLI)" : "认知负荷指数（CLI）"
    static let cliInfoContent = isUSVersion ?
        """
        The Cognitive Load Index reflects your brain's cognitive stress level over the past 24 hours.
        
        Calculation
        • Based on usage duration of High Dopamine Apps (HDA)
        • Longer usage results in higher CLI
        • Only counts data from the last 24 hours
        
        Values
        • 0-30: Good state, focused attention
        • 30-60: Starting to scatter, rest recommended
        • 60-90: High load, immediate rest needed
        • 90-100: Severe depletion, must stop usage
        
        Refresh Mechanism
        • Resets automatically after 24 hours
        • Every day is a fresh start
        
        Suggestions
        • Set up a monitor list to track distracting apps
        • Take a short meditation when CLI exceeds 30
        • Maintain a healthy state with daily CLI < 30
        """ :
        """
        认知负荷指数反映了你在过去 24 小时内大脑的认知压力水平。
        
        计算方式
        • 基于高多巴胺应用（HDA）的使用时长
        • 使用时间越长，CLI 越高
        • 仅统计最近 24 小时的数据
        
        数值含义
        • 0-30：良好状态，注意力集中
        • 30-60：开始分散，建议休息
        • 60-90：负荷较高，需要立即休息
        • 90-100：严重耗竭，必须停止使用
        
        刷新机制
        • 24 小时后自动重置
        • 每天都是新的开始
        
        建议
        • 设置监测列表，追踪分心应用
        • CLI 超过 30 时，进行短暂冥想
        • 保持每日 CLI < 30 的健康状态
        """
    
    // MARK: - MyStatsView (New)
    static let myStatsTitle = isUSVersion ? "My Stats" : "我的数据"
    static let minutesUnit = isUSVersion ? "min" : "分钟"
    static let daysUnit = isUSVersion ? "days" : "天"
    static let timesUnit = isUSVersion ? "times" : "次"
    
    static let currentStreakTitle = isUSVersion ? "Current Streak" : "连续天数"
    static let totalDaysTitle = isUSVersion ? "Total Days" : "总天数"
    static let completedSessionsTitle = isUSVersion ? "Sessions" : "完成次数"
    static let stabilityValueTitle = isUSVersion ? "Stability" : "稳定值"
    
    static let weeklyStats = isUSVersion ? "Weekly Stats" : "本周统计"
    static let emotionalLogsTitle = isUSVersion ? "Emotional Photolysis Logs" : "情绪光解记录"
    static let noEmotionalLogs = isUSVersion ? "No photolysis records yet" : "暂无光解记录"
    
    static let flowStabilityInfoContent = isUSVersion ?
        """
        Flow Stability reflects your focus state and mental stability.
        
        Focus Cycle Interruption Rate
        • Tracks completion of your focus sessions
        • Meditation: Completed if >80% of target duration
        • Other activities: Completed upon finishing
        • Interruption: Broken before reaching target
        • Lower interruption rate indicates stronger focus
        
        Flow Fluctuation Heatmap
        • Shows hourly stability changes over the past 7 days
        • Cyan: High stability (>70%)
        • Purple: Moderate stability (40-70%)
        • Dark Red: Low stability (<40%)
        • Helps identify your best and worst focus periods
        
        Data Source
        • Based on records from meditation, touch anchor, flow forging, etc.
        • Real-time tracking of stability trends
        """ :
        """
        心流稳定性反映你的专注状态和心理稳定程度。
        
        专注周期中断率
        • 统计你的专注会话完成情况
        • 冥想会话：达到目标时长的80%以上算完成
        • 其他活动：触感锚点、心流铸核、情绪光解等，完成即算成功
        • 中断：未达到目标时长就被打断
        • 中断率越低，说明专注能力越强
        
        心流波动热力图
        • 展示过去7天每小时的稳定值变化
        • 青色：高稳定状态（70%以上）
        • 紫色：中等稳定状态（40-70%）
        • 暗红：低稳定状态（40%以下）
        • 帮助你发现最佳和最差的专注时段
        
        数据来源
        • 基于你的冥想、触感锚点、心流铸核等活动记录
        • 实时追踪稳定值的变化趋势
        """
    
    static let digitalRelationInfoContent = isUSVersion ?
        """
        Digital Symbiosis analyzes your interaction patterns with digital devices.
        
        Digital Distraction Distribution
        • Statistics on HDA impact on stability
        • Grouped by app category
        • Impact Count: Number of times this category caused stability drop
        • Avg Drop: Average percentage drop per use
        
        App Categories
        • Social Ripples: Social media apps
        • Entertainment Vortex: Entertainment apps
        • Info Flood: News/Info apps
        • Digital Noise: Other distracting apps
        
        Data Source
        • Based on your HDA usage records
        • Tracks stability changes after each use
        • Helps identify most distracting app types
        """ :
        """
        数字共生关系分析你与数字设备的互动模式。
        
        数字分心分布
        • 统计高多巴胺应用（HDA）对稳定值的影响
        • 按应用类别分组展示
        • 影响次数：该类应用导致稳定值下降的次数
        • 平均下降：每次使用平均降低的稳定值百分比
        
        应用类别
        • 社交涟漪：社交类应用
        • 娱乐漩涡：娱乐类应用
        • 资讯洪流：新闻资讯类应用
        • 数字喧嚣：其他分心应用
        
        数据来源
        • 基于你的HDA使用记录
        • 追踪每次使用后的稳定值变化
        • 帮助你识别最影响专注的应用类型
        """
    
    static let meditationEchoInfoContent = isUSVersion ?
        """
        Serenity Echo shows the positive impact of meditation on your mental state.
        
        Meditation Improvement Effect
        • Records stability changes before and after each meditation
        • Bar height represents stability gain
        • Color gradient: Cyan to Purple
        • Shows up to last 10 meditation records
        
        Gain Calculation
        • Pre-Meditation SV: Stability at start
        • Post-Meditation SV: Stability at finish
        • Gain = Post - Pre
        • Improvement % = (Gain / Pre) * 100%
        
        Data Source
        • Based on your meditation activity records
        • Tracks duration and effect of each session
        • Helps understand meditation's impact on mental state
        """ :
        """
        宁静回响展示冥想对你心理状态的积极影响。
        
        冥想提升效果
        • 记录每次冥想前后的稳定值变化
        • 柱状图高度代表稳定值提升幅度
        • 颜色渐变：青色到紫色
        • 最多显示最近10次冥想记录
        
        提升计算
        • 冥想前SV值：开始冥想时的稳定值
        • 冥想后SV值：完成冥想后的稳定值
        • 提升幅度 = 冥想后 - 冥想前
        • 提升百分比 = (提升幅度 / 冥想前) × 100%
        
        数据来源
        • 基于你的冥想活动记录
        • 追踪每次冥想的时长和效果
        • 帮助你了解冥想对心理状态的改善程度
        """
    
    static let svInfoTitle = isUSVersion ? "Stability Value (SV)" : "稳定值（SV）"
    
    // MARK: - SubscriptionView (New)
    static let subMonthlyTitle = isUSVersion ? "Monthly" : "月度订阅"
    static let subYearlyTitle = isUSVersion ? "Yearly" : "年度订阅"
    static let subLifetimeTitle = isUSVersion ? "Lifetime" : "永久买断"
    
    static let subMonthlyPeriod = isUSVersion ? "/mo" : "/月"
    static let subYearlyPeriod = isUSVersion ? "/yr" : "/年"
    
    static let subYearlySavings = isUSVersion ? "Save $38" : "省 ¥88"
    static let subLifetimeSavings = isUSVersion ? "One-time" : "一次付费"
    static let subRecommendedBadge = isUSVersion ? "Best Value" : "推荐"
    
    static let subFeatureMusicTitle = isUSVersion ? "Exclusive Soundscapes" : "专属音景"
    static let subFeatureMusicDesc = isUSVersion ? "8 high-quality tracks" : "8首高品质冥想音乐"
    static let subFeatureMaterialsTitle = isUSVersion ? "Premium Materials" : "高级材质"
    static let subFeatureMaterialsDesc = isUSVersion ? "10 unique sphere visuals" : "10种独特球体视觉"
    static let subFeatureInsightsTitle = isUSVersion ? "Deep Insights" : "深度洞察"
    static let subFeatureInsightsDesc = isUSVersion ? "Comprehensive analysis" : "全方位数据分析报告"
    static let subFeatureFocusTitle = isUSVersion ? "Focus Tracking" : "专注追踪"
    static let subFeatureFocusDesc = isUSVersion ? "Real-time flow monitoring" : "心流状态实时监测"
    
    static let subFeatureDistractionTitle = isUSVersion ? "Distraction Monitor" : "分心监测"
    static let subFeatureDistractionDesc = isUSVersion ? "Digital habit analysis" : "数字习惯深度分析"
    static let subFeatureUpdatesTitle = isUSVersion ? "Continuous Updates" : "持续更新"
    static let subFeatureUpdatesDesc = isUSVersion ? "Priority access to new features" : "优先体验所有新功能"
    static let subFeatureCLITitle = isUSVersion ? "Cognitive Load" : "认知负荷"
    static let subFeatureCLIDesc = isUSVersion ? "Real-time mental state" : "实时脑力状态评估"
    static let subFeatureThemesTitle = isUSVersion ? "Curated Themes" : "精选主题"
    static let subFeatureThemesDesc = isUSVersion ? "Immersive dynamic backgrounds" : "沉浸式动态背景"
    
    static let subUnlockExperience = isUSVersion ? "Unlock the full journey of mental cultivation" : "解锁完整的心智修行体验"
    static let subSubscribeNow = isUSVersion ? "Subscribe Now" : "立即订阅"
    static let subBuyNow = isUSVersion ? "Buy Now" : "立即购买"
    static let subInfoText = isUSVersion ? "Subscription tied to your Apple ID, usable across devices" : "订阅绑定到您的 Apple ID，可在多设备使用"
    static let subRestorePurchase = isUSVersion ? "Restore Purchase" : "恢复购买"
    static let subRestoreNoRecord = isUSVersion ? "No purchasable record found" : "未找到可恢复的购买记录"
    static let subAlertTitle = isUSVersion ? "Notice" : "提示"
    
    static let subOriginalPrice = isUSVersion ? "$59.99" : "¥216"
    static let svInfoContent = isUSVersion ?
        """
        Stability Value represents your mental stability and is a cumulative metric.
        
        Gains (Daily First Time)
        • Meditation: 1 min = +1% (Max 30%)
        • Touch Anchor: +5%
        • Flow Forging: +8%
        • Emotion Photolysis: +7%
        
        Losses
        • Daily Natural Decay: -15%
        • HDA Usage: -10% per hour
        
        Maintaining Balance
        • Need at least +15% daily to counter decay
        • Recommended full routine: Meditation + Touch Anchor + Flow Forging + Emotion Photolysis
        • Full routine yields +20% or more, effectively countering decay
        
        Visual Feedback
        • SV directly affects the fluid sphere's motion
        • 100% Stability: Slow, small amplitude breathing and floating (Speed 0.2x, Amp 0.5x)
        • 50% Stability: Medium speed and amplitude (Speed 3.5x, Amp 1.9x)
        • 0% Stability: Fast, large amplitude violent motion (Speed 7.0x, Amp 3.5x)
        • Combined with CLI to determine the sphere's motion rate and amplitude
        • The sphere is a real-time visualization of your mental state
        
        Design Philosophy
        • SV does not reset daily; it is cumulative
        • Requires continuous effort to maintain
        • Encourages long-term mindfulness habits
        
        Balance Example
        • Full Routine: Meditation 10m (+10%) + Touch Anchor (+5%) + Flow Forging (+8%) + Emotion Photolysis (+7%) - Decay (-15%) = +15%
        • Meditation Only 30m: (+30%) - Decay (-15%) = +15%
        • No Activity: - Decay (-15%) = -15%
        """ :
        """
        稳定值代表你的心理稳定程度，是一个持续累积的指标。
        
        增长方式（每日首次）
        • 冥想：1 分钟 = +1%（上限 30%）
        • 触感锚点：+5%
        • 心流铸核：+8%
        • 情绪光解：+7%
        
        损失方式
        • 每日自然衰减：-15%
        • 使用 HDA：每小时 -10%
        
        维持平衡
        • 每天至少需要 +15% 来对抗衰减
        • 建议完成完整流程：冥想 + 触感锚点 + 心流铸核 + 情绪光解
        • 完整流程可获得 +20% 以上，有效对抗衰减
        
        流体光影球的视觉反馈
        • 稳定值直接影响流体光影球的运动状态
        • 100% 稳定：光球缓慢、小幅度地呼吸和漂浮（速度 0.2x，幅度 0.5x）
        • 50% 稳定：光球以中等速度和幅度运动（速度 3.5x，幅度 1.9x）
        • 0% 稳定：光球快速、大幅度地剧烈运动（速度 7.0x，幅度 3.5x）
        • 结合认知负荷指数（CLI），共同决定光球的运动速率和幅度
        • 光球是你心智状态的实时视觉化表现
        
        设计理念
        • SV 不会每日重置，是累积的
        • 需要持续投入才能维持
        • 鼓励养成长期正念习惯
        
        平衡示例
        • 完整流程：冥想 10 分钟 (+10%) + 触感锚点 (+5%) + 心流铸核 (+8%) + 情绪光解 (+7%) - 衰减 (-15%) = +15%
        • 仅冥想 30 分钟：(+30%) - 衰减 (-15%) = +15%
        • 不做任何活动：- 衰减 (-15%) = -15%
        """
    
    static let trendInfoTitle = isUSVersion ? "7-Day Trend" : "7日趋势"
    static let trendInfoContent = isUSVersion ?
        """
        The 7-Day Trend shows the trajectory of your Core Stability Index (CSI) over the past week.
        
        Core Stability Index (CSI)
        • Comprehensive assessment of your mental stability
        • Calculated based on Stability Value (SV) and Cognitive Load (CLI)
        • Formula: CSI = SV × (1 - CLI/100)
        
        Values
        • 70-100: Excellent state, stable flow
        • 40-70: Moderate state, needs attention
        • 0-40: At risk, immediate adjustment recommended
        
        Trend Analysis
        • Upward: Your mindfulness habits are working
        • Downward: May need to reduce HDA usage or increase meditation
        • High Fluctuation: Suggests establishing more stable daily habits
        
        Suggestions
        • Check the trend daily to understand your state changes
        • A steady upward trend is the optimal state
        • Combine with Deep Analysis page for more detailed insights
        
        Data Retention
        • Automatically records daily CSI values
        • Retains complete history
        • Chart shows trend for the last 7 days
        """ :
        """
        7日趋势展示你的核心稳定指数（CSI）在过去一周的变化轨迹。
        
        核心稳定指数（CSI）
        • 综合评估你的心理稳定状态
        • 基于稳定值（SV）和认知负荷（CLI）计算
        • 计算公式：CSI = SV × (1 - CLI/100)
        
        数值含义
        • 70-100：优秀状态，心流稳定
        • 40-70：中等状态，需要关注
        • 0-40：危险状态，建议立即调整
        
        趋势分析
        • 上升趋势：说明你的正念习惯在发挥作用
        • 下降趋势：可能需要减少 HDA 使用或增加冥想
        • 波动较大：建议建立更稳定的日常习惯
        
        使用建议
        • 每天查看趋势，了解自己的状态变化
        • 保持稳定的上升趋势是最佳状态
        • 结合深度解析页面，获取更详细的洞察
        
        数据保存
        • 自动记录每日的 CSI 数值
        • 保留完整历史数据
        • 图表显示最近 7 天的趋势
        """
    
    static let cliAlertTitle = isUSVersion ? "Cognitive Load Alert" : "认知负荷提醒"
    static let gotIt = isUSVersion ? "Got it" : "知道了"
    static let goToMeditate = isUSVersion ? "Meditate" : "去冥想"
    
    // MARK: - Insights (New)
    static let insightWeakestPeriod = isUSVersion ? "Your flow light is weakest between %@" : "你的心流之光，在%@最为脆弱。"
    static let insightRecoveryTime = isUSVersion ? "When your flow is chaotic, it usually takes %d minutes to return to clarity." : "当你的心流陷入混沌，通常需要%d分钟才能重归澄澈。"
    static let insightInterruption = isUSVersion ? "In recent focus journeys, you often feel mental fluctuations after %d minutes." : "在最近的专注旅程中，你常在%d分钟后，感到心境的波动。"
    static let insightSensitiveApp = isUSVersion ? "Your flow mirror is particularly sensitive to %@." : "你的心流之镜，对%@尤其敏感。"
    static let insightUsageImpact = isUSVersion ? "When digital noise occupies %d hours, your light of mind dims." : "当数字的喧嚣占据%d小时，你的心境之光便会黯淡。"
    static let insightDigitalGravity = isUSVersion ? "Digital gravity seems particularly strong during certain periods." : "在某些时段，数字的引力显得格外强大。"
    static let insightMeditationGain = isUSVersion ? "Meditation brings you a %.1f%% return of clarity energy." : "冥想，为你带来%.1f%%的澄澈能量回馈。"
    static let insightLongTermTrend = isUSVersion ? "Continuous serenity practice has quietly raised your flow baseline." : "持续的宁静实践，已让你的心流基线悄然上扬。"
    static let insightModeEffect = isUSVersion ? "Certain guide modes seem to touch your inner source of peace more effectively." : "某些引导模式，似乎更能触及你内心的平静之源。"
    
    static let timeAfternoon = isUSVersion ? "3 PM to 5 PM" : "午后3点至5点间"
    static let timeNight = isUSVersion ? "9 PM to 11 PM" : "夜晚9点至11点间"
    static let timeMorning = isUSVersion ? "9 AM to 11 AM" : "上午9点至11点间"
    
    static let categorySocial = isUSVersion ? "Social Media" : "社交媒体"
    static let categoryEntertainment = isUSVersion ? "Entertainment" : "娱乐"
    
    // MARK: - Profile (New)
    static let dayWithLumea = isUSVersion ? "Day %d with Lumea" : "与澄域相遇的第 %d 天"
    static let notLoggedIn = isUSVersion ? "Not Logged In" : "未登录"
    static let signInToSync = isUSVersion ? "Sign in to sync your journey" : "登录以同步你的冥想旅程"
    static let loginAccountAction = isUSVersion ? "Login Account" : "登录账户"
    static let logoutConfirmTitle = isUSVersion ? "Sign Out" : "退出"
    static let logoutConfirmMessage = isUSVersion ? "Are you sure you want to sign out?" : "确定要退出登录吗？"
    static let upgradeToPlus = isUSVersion ? "Upgrade" : "开通会员"
    
    static let monthlyExpires = isUSVersion ? "Monthly · Expires %@" : "月度会员 · 到期时间 %@"
    static let monthlyMember = isUSVersion ? "Monthly Member" : "月度会员"
    static let yearlyExpires = isUSVersion ? "Yearly · Expires %@" : "年度会员 · 到期时间 %@"
    static let yearlyMember = isUSVersion ? "Yearly Member" : "年度会员"
    static let lifetimeMember = isUSVersion ? "Lifetime · Thank you!" : "永久会员 · 感谢支持"
    static let unlockFullExperience = isUSVersion ? "Unlock the full experience" : "解锁完整的心智修行体验"
    
    // MARK: - Material Descriptions (New)
    static let descClassic = isUSVersion ? "Classic fluid light" : "经典流体光影"
    static let descLava = isUSVersion ? "Burning energy flow" : "炽热的能量涌动"
    static let descIce = isUSVersion ? "Pure crystal beauty" : "纯净的冰晶之美"
    static let descGold = isUSVersion ? "Warm golden glow" : "温暖的金色光辉"
    static let descAmber = isUSVersion ? "Warm amber tone" : "温暖的琥珀色泽"
    static let descNeon = isUSVersion ? "Futuristic electronic glow" : "未来感的电子光芒"
    static let descNebula = isUSVersion ? "Brilliant nebula colors" : "绚丽的星云色彩"
    static let descAurora = isUSVersion ? "Northern lights dance" : "北极光的绚丽舞动"
    static let descSakura = isUSVersion ? "Gentle pink romance" : "温柔的粉色浪漫"
    static let descOcean = isUSVersion ? "Serene ocean depths" : "宁静的海洋深处"
    static let descSunset = isUSVersion ? "Warm twilight moment" : "温暖的黄昏时刻"
    static let descForest = isUSVersion ? "Vibrant green vitality" : "生机盎然的绿意"
    static let descGalaxy = isUSVersion ? "Vast cosmic stars" : "浩瀚的宇宙星辰"
    static let descCrystal = isUSVersion ? "Pure crystal luster" : "纯净的水晶光泽"
    
    static let preview = isUSVersion ? "Preview" : "预览"
    static let freeMaterials = isUSVersion ? "Free Materials" : "免费材质"
    static let premiumExclusive = isUSVersion ? "Premium Exclusive" : "会员专属"
    static var isUSVersion: Bool {
        // 临时修复：直接检查 Bundle ID
        if let bundleId = Bundle.main.bundleIdentifier {
            return bundleId.contains(".us") // com.mercury.serenity.us
        }
        
        // 备用方案：检查编译标志
        #if US_VERSION
        return true
        #else
        return false
        #endif
    }
}
