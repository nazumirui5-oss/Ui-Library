-- ========================================================================
-- [[ LOUIS HUB - DYNAMIC ANIMATION & EMOTE INJECTION MODULE ]]
-- ========================================================================
return function(Window, Library)
    -- 1. Rig-Type Check (Non-obstructive)
    if not game.Players.LocalPlayer.Character or game.Players.LocalPlayer.Character:WaitForChild("Humanoid").RigType ~= Enum.HumanoidRigType.R15 then 
        Library:Notify("Rig Warning", "Your character is currently on R6. Custom animations require R15 rig-type!", 10)
        return
    end

    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- Setup Preset Database
    local OriginalAnimations = {
        ["Idle"] = {
            ["2016 Animation (mm2)"] = {"387947158", "387947464"}, 
            ["(UGC) Oh Really?"] = {"98004748982532", "98004748982532"}, 
            ["Astronaut"] = {"891621366", "891633237"}, 
            ["Adidas Community"] = {"122257458498464", "102357151005774"}, 
            ["Bold"] = {"16738333868", "16738334710"}, 
            ["(UGC) Slasher"] = {"140051337061095", "140051337061095"}, 
            ["(UGC) Retro"] = {"80479383912838", "80479383912838"}, 
            ["(UGC) Magician"] = {"139433213852503", "139433213852503"}, 
            ["(UGC) John Doe"] = {"72526127498800", "72526127498800"}, 
            ["(UGC) Noli"] = {"139360856809483", "139360856809483"}, 
            ["(UGC) Coolkid"] = {"95203125292023", "95203125292023"}, 
            ["(UGC) Survivor Injured"] = {"73905365652295", "73905365652295"}, 
            ["(UGC) Retro Zombie"] = {"90806086002292", "90806086002292"}, 
            ["(UGC) 1x1x1x1"] = {"76780522821306", "76780522821306"}, 
            ["Borock"] = {"3293641938", "3293642554"}, 
            ["Bubbly"] = {"910004836", "910009958"}, 
            ["Cartoony"] = {"742637544", "742638445"}, 
            ["Confident"] = {"1069977950", "1069987858"}, 
            ["Catwalk Glam"] = {"133806214992291", "94970088341563"}, 
            ["Cowboy"] = {"1014390418", "1014398616"}, 
            ["Drooling Zombie"] = {"3489171152", "3489171152"}, 
            ["Elder"] = {"10921101664", "10921102574"}, 
            ["Ghost"] = {"616006778", "616008087"}, 
            ["Knight"] = {"657595757", "657568135"}, 
            ["Levitation"] = {"616006778", "616008087"}, 
            ["Mage"] = {"707742142", "707855907"}, 
            ["MrToilet"] = {"4417977954", "4417978624"}, 
            ["Ninja"] = {"656117400", "656118341"}, 
            ["NFL"] = {"92080889861410", "74451233229259"}, 
            ["OldSchool"] = {"10921230744", "10921232093"}, 
            ["Patrol"] = {"1149612882", "1150842221"}, 
            ["Pirate"] = {"750781874", "750782770"}, 
            ["Default Retarget"] = {"95884606664820", "95884606664820"}, 
            ["Very Long"] = {"18307781743", "18307781743"}, 
            ["Sway"] = {"560832030", "560833564"}, 
            ["Popstar"] = {"1212900985", "1150842221"}, 
            ["Princess"] = {"941003647", "941013098"}, 
            ["R6"] = {"12521158637", "12521162526"}, 
            ["R15 Reanimated"] = {"4211217646", "4211218409"}, 
            ["Realistic"] = {"17172918855", "17173014241"}, 
            ["Robot"] = {"616088211", "616089559"}, 
            ["Sneaky"] = {"1132473842", "1132477671"}, 
            ["Sports (Adidas)"] = {"18537376492", "18537371272"}, 
            ["Soldier"] = {"3972151362", "3972151362"}, 
            ["Stylish"] = {"616136790", "616138447"}, 
            ["Stylized Female"] = {"4708191566", "4708192150"}, 
            ["Superhero"] = {"10921288909", "10921290167"}, 
            ["Toy"] = {"782841498", "782845736"}, 
            ["Udzal"] = {"3303162274", "3303162549"}, 
            ["Vampire"] = {"1083445855", "1083450166"}, 
            ["Werewolf"] = {"1083195517", "1083214717"}, 
            ["Wicked (Popular)"] = {"118832222982049", "76049494037641"}, 
            ["No Boundaries (Walmart)"] = {"18747067405", "18747063918"}, 
            ["Zombie"] = {"616158929", "616160636"}, 
            ["(UGC) Zombie"] = {"77672872857991", "77672872857991"}, 
            ["(UGC) TailWag"] = {"129026910898635", "129026910898635"}, 
            ["[VOTE] warming up"] = {"83573330053643", "83573330053643"}, 
            ["cesus"] = {"115879733952840", "115879733952840"}, 
            ["[VOTE] Float"] = {"110375749767299", "110375749767299"}, 
            ["UGC Oneleft"] = {"121217497452435", "121217497452435"}, 
            ["AuraFarming"] = {"138665010911335", "138665010911335"}, 
            ["[VOTE] Mech Float"] = {"74447366032908", "74447366032908"}, 
            ["Badware"] = {"140131631438778", "140131631438778"}, 
            ["Wicked \"Dancing Through Life\""] = {"92849173543269", "132238900951109"}, 
            ["Unboxed By Amazon"] = {"98281136301627", "138183121662404"}
        }, 
        ["Walk"] = {
            ["Geto"] = "85811471336028", 
            ["Patrol"] = "1151231493", 
            ["Drooling Zombie"] = "3489174223", 
            ["Adidas Community"] = "122150855457006", 
            ["Levitation"] = "616013216", 
            ["Catwalk Glam"] = "109168724482748", 
            ["Knight"] = "10921127095", 
            ["Pirate"] = "750785693", 
            ["Bold"] = "16738340646", 
            ["Sports (Adidas)"] = "18537392113", 
            ["Zombie"] = "616168032", 
            ["Astronaut"] = "891667138", 
            ["Cartoony"] = "742640026", 
            ["Ninja"] = "656121766", 
            ["Confident"] = "1070017263", 
            ["Wicked \"Dancing Through Life\""] = "73718308412641", 
            ["Unboxed By Amazon"] = "90478085024465", 
            ["Gojo"] = "95643163365384", 
            ["R15 Reanimated"] = "4211223236", 
            ["Ghost"] = "616013216", 
            ["2016 Animation (mm2)"] = "387947975", 
            ["(UGC) Zombie"] = "113603435314095", 
            ["No Boundaries (Walmart)"] = "18747074203", 
            ["Rthro"] = "10921269718", 
            ["Werewolf"] = "1083178339", 
            ["Wicked (Popular)"] = "92072849924640", 
            ["Vampire"] = "1083473930", 
            ["Popstar"] = "1212980338", 
            ["Mage"] = "707897309", 
            ["(UGC) Smooth"] = "76630051272791", 
            ["R6"] = "12518152696", 
            ["NFL"] = "110358958299415", 
            ["Bubbly"] = "910034870", 
            ["(UGC) Retro"] = "107806791584829", 
            ["(UGC) Retro Zombie"] = "140703855480494", 
            ["OldSchool"] = "10921244891", 
            ["Elder"] = "10921111375", 
            ["Stylish"] = "616146177", 
            ["Stylized Female"] = "4708193840", 
            ["Robot"] = "616095330", 
            ["Sneaky"] = "1132510133", 
            ["Superhero"] = "10921298616", 
            ["Udzal"] = "3303162967", 
            ["Toy"] = "782843345", 
            ["Default Retarget"] = "115825677624788", 
            ["Princess"] = "941028902", 
            ["Cowboy"] = "1014421541"
        }, 
        ["Run"] = {
            ["Robot"] = "10921250460", 
            ["Patrol"] = "1150967949", 
            ["Drooling Zombie"] = "3489173414", 
            ["Adidas Community"] = "82598234841035", 
            ["Heavy Run (Udzal / Borock)"] = "3236836670", 
            ["Catwalk Glam"] = "81024476153754", 
            ["Knight"] = "10921121197", 
            ["Pirate"] = "750783738", 
            ["Bold"] = "16738337225", 
            ["Sports (Adidas)"] = "18537384940", 
            ["Zombie"] = "616163682", 
            ["Astronaut"] = "10921039308", 
            ["Cartoony"] = "10921076136", 
            ["Ninja"] = "656118852", 
            ["(UGC) Dog"] = "130072963359721", 
            ["Wicked \"Dancing Through Life\""] = "135515454877967", 
            ["Unboxed By Amazon"] = "134824450619865", 
            ["[UGC] Flipping"] = "124427738251511", 
            ["Sneaky"] = "1132494274", 
            ["R6"] = "12518152696", 
            ["[VOTE] Aura"] = "120142877225965", 
            ["Popstar"] = "1212980348", 
            ["Wicked (Popular)"] = "72301599441680", 
            ["[UGC] chibi"] = "85887415033585", 
            ["R15 Reanimated"] = "4211220381", 
            ["Mage"] = "10921148209", 
            ["Ghost"] = "616013216", 
            ["Rthro"] = "10921261968", 
            ["Confident"] = "1070001516", 
            ["Stylized Female"] = "4708192705", 
            ["No Boundaries (Walmart)"] = "18747070484", 
            ["Elder"] = "10921104374", 
            ["Werewolf"] = "10921336997", 
            ["[UGC] Girly"] = "128578785610052", 
            ["Stylish"] = "10921276116", 
            ["(UGC) Pride"] = "116462200642360", 
            ["NFL"] = "117333533048078", 
            ["(UGC) Soccer"] = "116881956670910", 
            ["MrToilet"] = "4417979645", 
            ["[VOTE] Float"] = "71267457613791", 
            ["Levitation"] = "616010382", 
            ["(UGC) Retro"] = "107806791584829", 
            ["(UGC) Retro Zombie"] = "140703855480494", 
            ["OldSchool"] = "10921240218", 
            ["Vampire"] = "10921320299", 
            ["furry"] = "102269417125238", 
            ["Bubbly"] = "10921057244", 
            ["fake wicked"] = "138992096476836", 
            ["2016 Animation (mm2)"] = "387947975", 
            ["[UGC] ball"] = "132499588684957", 
            ["Superhero"] = "10921291831", 
            ["Toy"] = "10921306285", 
            ["Default Retarget"] = "102294264237491", 
            ["Princess"] = "941015281", 
            ["Cowboy"] = "1014401683"
        }, 
        ["Jump"] = {
            ["Robot"] = "616090535", 
            ["Patrol"] = "1148811837", 
            ["Adidas Community"] = "75290611992385", 
            ["Levitation"] = "616008936", 
            ["Catwalk Glam"] = "116936326516985", 
            ["Knight"] = "910016857", 
            ["Pirate"] = "750782230", 
            ["Bold"] = "16738336650", 
            ["Sports (Adidas)"] = "18537380791", 
            ["Zombie"] = "616161997", 
            ["Astronaut"] = "891627522", 
            ["Cartoony"] = "742637942", 
            ["Ninja"] = "656117878", 
            ["Confident"] = "1069984524", 
            ["Wicked \"Dancing Through Life\""] = "78508480717326", 
            ["Unboxed By Amazon"] = "121454505477205", 
            ["R6"] = "12520880485", 
            ["R15 Reanimated"] = "4211219390", 
            ["Ghost"] = "616008936", 
            ["Rthro"] = "10921263860", 
            ["No Boundaries (Walmart)"] = "18747069148", 
            ["Werewolf"] = "1083218792", 
            ["Cowboy"] = "1014394726", 
            ["UGC"] = "91788124131212", 
            ["[VOTE] Animal"] = "131203832825082", 
            ["Popstar"] = "1212954642", 
            ["Mage"] = "10921149743", 
            ["Sneaky"] = "1132489853", 
            ["Superhero"] = "10921294559", 
            ["Elder"] = "10921107367", 
            ["(UGC) Retro"] = "139390570947836", 
            ["NFL"] = "119846112151352", 
            ["OldSchool"] = "10921242013", 
            ["Stylized Female"] = "4708188025", 
            ["Stylish"] = "616139451", 
            ["Bubbly"] = "910016857", 
            ["[VOTE] Float"] = "75611679208549", 
            ["[VOTE] Aura"] = "93382302369459", 
            ["Vampire"] = "1083455352", 
            ["Wicked (Popular)"] = "104325245285198", 
            ["Toy"] = "10921308158", 
            ["Default Retarget"] = "117150377950987", 
            ["Princess"] = "941008832", 
            ["[UGC] happy"] = "72388373557525"
        }, 
        ["Fall"] = {
            ["Robot"] = "616087089", 
            ["Patrol"] = "1148863382", 
            ["Adidas Community"] = "98600215928904", 
            ["Levitation"] = "616005863", 
            ["Catwalk Glam"] = "92294537340807", 
            ["Knight"] = "10921122579", 
            ["Pirate"] = "750780242", 
            ["Bold"] = "16738333171", 
            ["Sports (Adidas)"] = "18537367238", 
            ["Zombie"] = "616157476", 
            ["Astronaut"] = "891617961", 
            ["Cartoony"] = "742637151", 
            ["Ninja"] = "656115606", 
            ["Confident"] = "1069973677", 
            ["Wicked \"Dancing Through Life\""] = "78147885297412", 
            ["Unboxed By Amazon"] = "94788218468396", 
            ["R6"] = "12520972571", 
            ["[UGC] skydiving"] = "102674302534126", 
            ["R15 Reanimated"] = "4211216152", 
            ["Rthro"] = "10921262864", 
            ["No Boundaries (Walmart)"] = "18747062535", 
            ["Werewolf"] = "1083189019", 
            ["[VOTE] TPose"] = "139027266704971", 
            ["Mage"] = "707829716", 
            ["[VOTE] Animal"] = "77069224396280", 
            ["Wicked (Popular)"] = "121152442762481", 
            ["Popstar"] = "1212900995", 
            ["NFL"] = "129773241321032", 
            ["OldSchool"] = "10921241244", 
            ["Sneaky"] = "1132469004", 
            ["Elder"] = "10921105765", 
            ["Bubbly"] = "910001910", 
            ["Stylish"] = "616134815", 
            ["Stylized Female"] = "4708186162", 
            ["Vampire"] = "1083443587", 
            ["Superhero"] = "10921293373", 
            ["Toy"] = "782846423", 
            ["Default Retarget"] = "110205622518029", 
            ["Princess"] = "941000007", 
            ["Cowboy"] = "1014384571"
        }, 
        ["SwimIdle"] = {
            ["Sneaky"] = "1132506407", 
            ["SuperHero"] = "10921297391", 
            ["Adidas Community"] = "109346520324160", 
            ["Levitation"] = "10921139478", 
            ["Catwalk Glam"] = "98854111361360", 
            ["Knight"] = "10921125935", 
            ["Pirate"] = "750785176", 
            ["Bold"] = "16738333171", 
            ["Sports (Adidas)"] = "18537387180", 
            ["Stylized"] = "4708190607", 
            ["Astronaut"] = "891663592", 
            ["Cartoony"] = "10921079380", 
            ["Wicked (Popular)"] = "113199415118199", 
            ["Mage"] = "707894699", 
            ["Wicked \"Dancing Through Life\""] = "129183123083281", 
            ["Unboxed By Amazon"] = "129126268464847", 
            ["R6"] = "12518152696", 
            ["Rthro"] = "10921265698", 
            ["CowBoy"] = "1014411816", 
            ["No Boundaries (Walmart)"] = "18747071682", 
            ["Werewolf"] = "10921341319", 
            ["NFL"] = "79090109939093", 
            ["OldSchool"] = "10921244018", 
            ["Robot"] = "10921253767", 
            ["Elder"] = "10921110146", 
            ["Bubbly"] = "910030921", 
            ["Patrol"] = "1151221899", 
            ["Vampire"] = "10921325443", 
            ["Popstar"] = "1212998578", 
            ["Ninja"] = "656118341", 
            ["Toy"] = "10921310341", 
            ["Confident"] = "1070012133", 
            ["Princess"] = "941025398", 
            ["Stylish"] = "10921281964"
        }, 
        ["Swim"] = {
            ["Sneaky"] = "1132500520", 
            ["Patrol"] = "1151204998", 
            ["Adidas Community"] = "133308483266208", 
            ["Levitation"] = "10921138209", 
            ["Catwalk Glam"] = "134591743181628", 
            ["Knight"] = "10921125160", 
            ["Pirate"] = "750784579", 
            ["Bold"] = "16738339158", 
            ["Sports (Adidas)"] = "18537389531", 
            ["Zombie"] = "616165109", 
            ["Astronaut"] = "891663592", 
            ["Cartoony"] = "10921079380", 
            ["Wicked (Popular)"] = "99384245425157", 
            ["Mage"] = "707876443", 
            ["PopStar"] = "1212998578", 
            ["Unboxed By Amazon"] = "105962919001086", 
            ["R6"] = "12518152696", 
            ["Rthro"] = "10921264784", 
            ["CowBoy"] = "1014406523", 
            ["No Boundaries (Walmart)"] = "18747073181", 
            ["Werewolf"] = "10921340419", 
            ["NFL"] = "132697394189921", 
            ["OldSchool"] = "10921243048", 
            ["Wicked \"Dancing Through Life\""] = "110657013921774", 
            ["Elder"] = "10921108971", 
            ["Bubbly"] = "910028158", 
            ["Robot"] = "10921253142", 
            ["Vampire"] = "10921324408", 
            ["Stylish"] = "10921281000", 
            ["Toy"] = "10921309319", 
            ["SuperHero"] = "10921295495", 
            ["Princess"] = "941018893", 
            ["Confident"] = "1070009914"
        }, 
        ["Climb"] = {
            ["Robot"] = "616086039", 
            ["Patrol"] = "1148811837", 
            ["Adidas Community"] = "88763136693023", 
            ["Levitation"] = "10921132092", 
            ["Catwalk Glam"] = "119377220967554", 
            ["Knight"] = "10921125160", 
            ["Bold"] = "16738332169", 
            ["Sports (Adidas)"] = "18537363391", 
            ["Zombie"] = "616156119", 
            ["Astronaut"] = "10921032124", 
            ["Cartoony"] = "742636889", 
            ["Ninja"] = "656114359", 
            ["Confident"] = "1069946257", 
            ["Wicked \"Dancing Through Life\""] = "129447497744818", 
            ["Unboxed By Amazon"] = "121145883950231", 
            ["R6"] = "12520982150", 
            ["Ghost"] = "616003713", 
            ["Rthro"] = "10921257536", 
            ["CowBoy"] = "1014380606", 
            ["No Boundaries (Walmart)"] = "18747060903", 
            ["Mage"] = "707826056", 
            ["Reanimated R15"] = "4211214992", 
            ["Popstar"] = "1213044953", 
            ["NFL"] = "134630013742019", 
            ["OldSchool"] = "10921229866", 
            ["Sneaky"] = "1132461372", 
            ["Elder"] = "845392038", 
            ["Stylized Female"] = "4708184253", 
            ["Stylish"] = "10921271391", 
            ["SuperHero"] = "10921286911", 
            ["WereWolf"] = "10921329322", 
            ["Vampire"] = "1083439238", 
            ["Toy"] = "10921300839", 
            ["Wicked (Popular)"] = "131326830509784", 
            ["Princess"] = "940996062"
        }
    }

    local Animations = {}
    local fileAnimations = {}
    local lastAnimations = {}

    -- Load Local File Cache
    if isfile("GreyLikesToSmellUrFeet.json") then
        local data = readfile("GreyLikesToSmellUrFeet.json")
        pcall(function() 
            Animations = HttpService:JSONDecode(data) 
            fileAnimations = HttpService:JSONDecode(data) 
        end)
    else
        Animations = HttpService:JSONDecode(HttpService:JSONEncode(OriginalAnimations))
        fileAnimations = HttpService:JSONDecode(HttpService:JSONEncode(OriginalAnimations))
        writefile("GreyLikesToSmellUrFeet.json", HttpService:JSONEncode(OriginalAnimations))
    end

    -- Core Movement/Physics states
    local function freeze()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.PlatformStand = true
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and not part.Anchored then
                part.Anchored = true
            end
        end
    end

    local function unfreeze()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.PlatformStand = false
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Anchored then
                part.Anchored = false
            end
        end
    end

    local function refresh()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    end

    local function refreshswim()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        task.wait(0.1)
        humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
    end

    local function refreshclimb()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        task.wait(0.1)
        humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
    end

    local function StopAnim()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum = character:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                track:Stop(0)
            end
        end
    end

    -- Physics Reset Utilities
    local function ResetIdle()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then for _, v in next, hum:GetPlayingAnimationTracks() do v:Stop(0) end end
        pcall(function()
            local Animate = char.Animate
            Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=0"
            Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=0"
        end)
    end

    local function ResetWalk()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then for _, v in next, hum:GetPlayingAnimationTracks() do v:Stop(0) end end
        pcall(function() char.Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=0" end)
    end

    local function ResetRun()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then for _, v in next, hum:GetPlayingAnimationTracks() do v:Stop(0) end end
        pcall(function() char.Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=0" end)
    end

    local function ResetJump()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then for _, v in next, hum:GetPlayingAnimationTracks() do v:Stop(0) end end
        pcall(function() char.Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=0" end)
    end

    local function ResetFall()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then for _, v in next, hum:GetPlayingAnimationTracks() do v:Stop(0) end end
        pcall(function() char.Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=0" end)
    end

    local function ResetSwim()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then for _, v in next, hum:GetPlayingAnimationTracks() do v:Stop(0) end end
        pcall(function()
            local Animate = char.Animate
            if Animate.swim then Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=0" end
        end)
    end

    local function ResetSwimIdle()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then for _, v in next, hum:GetPlayingAnimationTracks() do v:Stop(0) end end
        pcall(function()
            local Animate = char.Animate
            if Animate.swimidle then Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=0" end
        end)
    end

    local function ResetClimb()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then for _, v in next, hum:GetPlayingAnimationTracks() do v:Stop(0) end end
        pcall(function() char.Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=0" end)
    end

    -- Animation Applier
    local function setAnimation(animationType, animationId)
        if type(animationId) ~= "table" and type(animationId) ~= "string" then return end
        local Char = LocalPlayer.Character
        if not Char then return end
        local Animate = Char:FindFirstChild("Animate")
        if not Animate then return end

        freeze()
        task.wait(0.1)

        local success, err = pcall(function()
            if animationType == "Idle" then
                lastAnimations.Idle = animationId
                ResetIdle()
                Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId[1]
                Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId[2]
                refresh()
            elseif animationType == "Walk" then
                lastAnimations.Walk = animationId
                ResetWalk()
                Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                refresh()
            elseif animationType == "Run" then
                lastAnimations.Run = animationId
                ResetRun()
                Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                refresh()
            elseif animationType == "Jump" then
                lastAnimations.Jump = animationId
                ResetJump()
                Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                refresh()
            elseif animationType == "Fall" then
                lastAnimations.Fall = animationId
                ResetFall()
                Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                refresh()
            elseif animationType == "Swim" and Animate:FindFirstChild("swim") then
                lastAnimations.Swim = animationId
                ResetSwim()
                Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                refreshswim()
            elseif animationType == "SwimIdle" and Animate:FindFirstChild("swimidle") then
                lastAnimations.SwimIdle = animationId
                ResetSwimIdle()
                Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                refreshswim()
            elseif animationType == "Climb" then
                lastAnimations.Climb = animationId
                ResetClimb()
                Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                refreshclimb()
            end
            
            pcall(function()
                writefile("MeWhenUrMom.json", HttpService:JSONEncode(lastAnimations))
            end)
        end)

        if not success then warn("Failed to set animation: ", err) end
        task.wait(0.1)
        unfreeze()
    end

    local function loadLastAnimations()
        if isfile("MeWhenUrMom.json") then
            local data = readfile("MeWhenUrMom.json")
            local lastAnimationsData = HttpService:JSONDecode(data)
            Library:Notify("Animations", "Loading saved animations configuration...", 2)
            
            if lastAnimationsData.Idle then setAnimation("Idle", lastAnimationsData.Idle) end
            if lastAnimationsData.Walk then setAnimation("Walk", lastAnimationsData.Walk) end
            if lastAnimationsData.Run then setAnimation("Run", lastAnimationsData.Run) end
            if lastAnimationsData.Jump then setAnimation("Jump", lastAnimationsData.Jump) end
            if lastAnimationsData.Fall then setAnimation("Fall", lastAnimationsData.Fall) end
            if lastAnimationsData.Climb then setAnimation("Climb", lastAnimationsData.Climb) end
            if lastAnimationsData.Swim then setAnimation("Swim", lastAnimationsData.Swim) end
            if lastAnimationsData.SwimIdle then setAnimation("SwimIdle", lastAnimationsData.SwimIdle) end
        end
    end

    -- Character added handler for persistence
    LocalPlayer.CharacterAdded:Connect(function(character)
        local hum = character:WaitForChild("Humanoid")
        local animate = character:WaitForChild("Animate", 10)
        if not animate then return end
        
        task.wait(0.5)
        if lastAnimations.Idle then setAnimation("Idle", lastAnimations.Idle) end
        if lastAnimations.Walk then setAnimation("Walk", lastAnimations.Walk) end
        if lastAnimations.Run then setAnimation("Run", lastAnimations.Run) end
        if lastAnimations.Jump then setAnimation("Jump", lastAnimations.Jump) end
        if lastAnimations.Fall then setAnimation("Fall", lastAnimations.Fall) end
        if lastAnimations.Climb then setAnimation("Climb", lastAnimations.Climb) end
        if lastAnimations.Swim then setAnimation("Swim", lastAnimations.Swim) end
        if lastAnimations.SwimIdle then setAnimation("SwimIdle", lastAnimations.SwimIdle) end
    end)

    -- Dynamic Dropdown List Generator
    local function getCategoryKeys(catName)
        local keys = {}
        if Animations[catName] then
            for name, _ in pairs(Animations[catName]) do
                table.insert(keys, name)
            end
        end
        table.sort(keys)
        return keys
    end

    -- ========================================================
    -- [[ INJECT ANIMATION TAB TO EXISTING WINDOW ]]
    -- ========================================================
    local TabAnim = Window:CreateTab("Animations", "rbxassetid://4483362458")

    TabAnim:CreateParagraph("Animation Changer", "Select and equip custom R15 physics animations natively.")

    -- Equippers Dropdown
    local IdleDrop = TabAnim:CreateDropdown("Equip Idle Animation", getCategoryKeys("Idle"), "", "EquipIdle", function(selected)
        local animId = Animations["Idle"][selected]
        if animId then setAnimation("Idle", animId) end
    end)

    local WalkDrop = TabAnim:CreateDropdown("Equip Walk Animation", getCategoryKeys("Walk"), "", "EquipWalk", function(selected)
        local animId = Animations["Walk"][selected]
        if animId then setAnimation("Walk", animId) end
    end)

    local RunDrop = TabAnim:CreateDropdown("Equip Run Animation", getCategoryKeys("Run"), "", "EquipRun", function(selected)
        local animId = Animations["Run"][selected]
        if animId then setAnimation("Run", animId) end
    end)

    local JumpDrop = TabAnim:CreateDropdown("Equip Jump Animation", getCategoryKeys("Jump"), "", "EquipJump", function(selected)
        local animId = Animations["Jump"][selected]
        if animId then setAnimation("Jump", animId) end
    end)

    local FallDrop = TabAnim:CreateDropdown("Equip Fall Animation", getCategoryKeys("Fall"), "", "EquipFall", function(selected)
        local animId = Animations["Fall"][selected]
        if animId then setAnimation("Fall", animId) end
    end)

    local SwimDrop = TabAnim:CreateDropdown("Equip Swim Animation", getCategoryKeys("Swim"), "", "EquipSwim", function(selected)
        local animId = Animations["Swim"][selected]
        if animId then setAnimation("Swim", animId) end
    end)

    local SwimIdleDrop = TabAnim:CreateDropdown("Equip SwimIdle Animation", getCategoryKeys("SwimIdle"), "", "EquipSwimIdle", function(selected)
        local animId = Animations["SwimIdle"][selected]
        if animId then setAnimation("SwimIdle", animId) end
    end)

    local ClimbDrop = TabAnim:CreateDropdown("Equip Climb Animation", getCategoryKeys("Climb"), "", "EquipClimb", function(selected)
        local animId = Animations["Climb"][selected]
        if animId then setAnimation("Climb", animId) end
    end)

    local function refreshUIOptions()
        IdleDrop:Refresh(getCategoryKeys("Idle"))
        WalkDrop:Refresh(getCategoryKeys("Walk"))
        RunDrop:Refresh(getCategoryKeys("Run"))
        JumpDrop:Refresh(getCategoryKeys("Jump"))
        FallDrop:Refresh(getCategoryKeys("Fall"))
        SwimDrop:Refresh(getCategoryKeys("Swim"))
        SwimIdleDrop:Refresh(getCategoryKeys("SwimIdle"))
        ClimbDrop:Refresh(getCategoryKeys("Climb"))
    end

    -- Sync Online Database Features
    TabAnim:CreateParagraph("Database Synchronization", "Synchronize list with developers' database.")
    TabAnim:CreateButton("Update Animations Database", function()
        local success, result = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/Gazer-Ha/Gaze-stuff/refs/heads/main/Gaze%20Anim%20Database")
        end)
        
        if success and result then
            local func, err = loadstring(result)
            if func then
                local ok, data = pcall(func)
                if ok and type(data) == "table" then
                    local changes = false
                    for cat, anims in pairs(data) do
                        Animations[cat] = Animations[cat] or {}
                        for name, ids in pairs(anims) do
                            if not Animations[cat][name] then
                                Animations[cat][name] = ids
                                changes = true
                            end
                        end
                    end
                    if changes then
                        writefile("GreyLikesToSmellUrFeet.json", HttpService:JSONEncode(Animations))
                        refreshUIOptions()
                        Library:Notify("Database Update", "New animations merged successfully!", 3)
                    else
                        Library:Notify("Database Sync", "Your database is already up to date.", 3)
                    end
                end
            end
        else
            Library:Notify("Database Error", "Failed to retrieve database contents.", 3)
        end
    end)

    -- Custom Animation Addition Section
    TabAnim:CreateParagraph("Add Custom Animations", "Inject your own animation asset IDs manually.")
    local addName, addCategory, addId1, addId2 = "", "Idle", "", ""

    TabAnim:CreateTextBox("Animation Name", "Enter name...", "AddAnimName", function(val) addName = val end)
    TabAnim:CreateDropdown("Animation Category", {"Idle", "Walk", "Run", "Jump", "Fall", "Swim", "SwimIdle", "Climb"}, "Idle", "AddAnimCat", function(selected) addCategory = selected end)
    TabAnim:CreateTextBox("Primary Asset ID", "Numeric ID...", "AddAnimId1", function(val) addId1 = val end)
    TabAnim:CreateTextBox("Secondary ID (Idle Only)", "Numeric ID...", "AddAnimId2", function(val) addId2 = val end)

    TabAnim:CreateButton("Create Custom Animation", function()
        if addName ~= "" and addId1 ~= "" then
            Animations[addCategory] = Animations[addCategory] or {}
            
            if addCategory == "Idle" then
                local firstId = tonumber(addId1) or addId1
                local secondId = tonumber(addId2) or addId2 or firstId
                Animations[addCategory][addName] = {tostring(firstId), tostring(secondId)}
            else
                local cleanId = tonumber(addId1) or addId1
                Animations[addCategory][addName] = tostring(cleanId)
            end

            writefile("GreyLikesToSmellUrFeet.json", HttpService:JSONEncode(Animations))
            refreshUIOptions()
            Library:Notify("Creation Complete", "Added " .. addName .. " to " .. addCategory .. " tab!", 3)
        else
            Library:Notify("Incomplete Data", "Please specify a name and asset ID before creation.", 3)
        end
    end)

    -- Playable Client Emote Actions
    local function PlayEmote(animationId)
        StopAnim()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://" .. animationId
        
        local track = humanoid:LoadAnimation(animation)
        track:Play()

        local checkConnection
        checkConnection = RunService.RenderStepped:Connect(function()
            if humanoid.MoveDirection.Magnitude > 0 then
                track:Stop()
                checkConnection:Disconnect()
            end
        end)
    end

    TabAnim:CreateParagraph("Client Emotes", "Play aesthetic dance emotes locally.")
    TabAnim:CreateDropdown("Equip Emote Pack", {"Dance 1", "Dance 2", "Dance 3", "Cheer", "Laugh", "Point", "Wave"}, "Dance 1", "EquipEmote", function(selected)
        local list = {
            ["Dance 1"] = "12521009666",
            ["Dance 2"] = "12521169800",
            ["Dance 3"] = "12521178362",
            ["Cheer"] = "12521021991",
            ["Laugh"] = "12521018724",
            ["Point"] = "12521007694",
            ["Wave"] = "12521004586"
        }
        local assetId = list[selected]
        if assetId then PlayEmote(assetId) end
    end)

    -- Load Initial settings
    task.spawn(loadLastAnimations)
end
