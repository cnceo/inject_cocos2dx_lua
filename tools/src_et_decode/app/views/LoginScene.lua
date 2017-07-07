local gt = cc.exports.gt

require("app/DefineConfig")
require("app/LuaBridge")
require("app/views/GlobalMethods")
local loginStrategy = require("app/LoginIpStrategy")

local LoginScene = class("LoginScene", function()
	return cc.Scene:create()
end)

function LoginScene:ctor()

	self.wxLoginIP = {"101.226.212.27","183.61.49.149","183.57.48.62","120.204.0.120","101.227.162.120","58.246.220.31","140.207.119.12"}

	-- 重新设置搜索路径
	local writePath = cc.FileUtils:getInstance():getWritablePath()
	local resSearchPaths = {
		writePath,
		writePath .. "src_et/",
		writePath .. "src/",
		writePath .. "res/sd/",
		writePath .. "res/sfx/",
		writePath .. "res/",
		"src_et/",
		"src/",
		"res/sd/",
		"res/sfx/",
		"res/"
	}

	cc.FileUtils:getInstance():setSearchPaths(resSearchPaths)
	
	gt.isInReview = false

	gt.debugMode = false

	gt.debugIpGet = false

	gt.pcLogin = false

	gt.activityControl = false

	gt.isZan = false

	--金币场开关	true为关闭 false为开启！！！
	gt.GoldControl = false

	--是否显示更新内容提示框，大版本更新的时候才显示，小版本更新 不想让显示更新内容的时候 设置成false
	gt.isShowUpdateView = false

	gt.robotNum = 0

	gt.IsShowSprjiang = 0
	--初始化活动信息
	gt.m_IsShare = 0 	--分享赠房卡 0 活动未开启 1 活动开启，未分享 2 活动开启，已分享
	gt.ShareString = "" --分享赠房卡活动信息

	gt.shareWeb = "http://a.app.qq.com/o/simple.jsp?pkgname=com.mahjong.sichuang"--"www.xianlaihy.com/sichuang"

	gt.shareiosWeb = "http://a.app.qq.com/o/simple.jsp?pkgname=com.mahjong.sichuang"

	gt.shareRoomIdUrl = "http://app.xianlaigame.com/mahjong.html"

	-- gt.NameTab = {"xianLai1516【微信】","XLYX555【微信】","XLYX333【微信】","xiongmao5111【微信】","xianLai3399【微信】","xLdy008【微信】","scmj521【微信】","xmpp222【微信】","xL2017310【微信】","xmxm1949【微信】","xianLai741【微信】","xiaomao257【微信】"}
	gt.NameTab = {"xmxmxm741【微信】","scmj521【微信】","xlyx333【微信】","xianlai741【微信】","xiongmao5111【微信】"}

	gt.AllGameType = {101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120}

	gt.roomState = 0	--房间类型初始化0

	--两次延迟大于500连接的中转服务器IP
	gt.transitIPArray = {"120.76.96.196","120.76.194.75","120.76.74.160","120.76.192.53","120.76.193.44",
						"120.76.194.154","120.76.75.2","120.76.193.221","120.76.193.7","120.76.156.122",
						"120.76.159.136","120.76.194.94","120.76.158.233","120.76.96.162","120.76.194.68",
						"120.76.97.49","120.76.99.132","120.76.156.201","120.76.96.167","120.76.156.121",
						"120.76.96.175","120.76.158.1","120.76.72.24","120.76.73.58","120.76.99.146",
						"120.76.96.148","120.76.74.153","120.76.73.68","120.76.193.142","120.76.156.178",
						"120.76.96.230","120.76.99.140","120.76.194.127","120.76.96.56","120.76.98.85",
						"120.76.99.151","120.76.156.72","120.76.75.17","120.76.96.149","120.76.99.127",
   						"120.76.98.241","120.76.40.184","120.76.75.113","120.76.99.31","120.76.75.196",
   						"120.76.156.21","120.76.194.176","120.76.156.113","120.76.96.158","120.76.194.64"
}

	-- 初始化Socket网络通信
	gt.socket = require("socket")
	local timenow = gt.socket.gettime()
	gt.transitIP = gt.transitIPArray[math.floor(timenow*1000) % #gt.transitIPArray+1]
	gt.log("gt.transitIP = "..gt.transitIP)

	gt.soundManager = require("app/SoundManager")

	gt.tools = require("app/Tools")

	if gt.isIOSPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaoc")
	elseif gt.isAndroidPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaj")
	end

	-- 初始化呀呀云sdk
	if gt.isUseNewMusic() == true then
		if gt.isIOSPlatform() then
			local ok = self.luaBridge.callStaticMethod("AppController", "createYayaSDK", 
				{appid = gt.audioAppID, audioPath = gt.audioIntPath, isDebug = "false", oversea = "false"})
		end
	end
	
	self:initPurchaseInfo()

	-- cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("images/LoginScene.plist")
	cc.SpriteFrameCache:getInstance():removeSpriteFrames()
	cc.SpriteFrameCache:getInstance():addSpriteFrames("images/LoginScene.plist")

	--大小牌
	cc.SpriteFrameCache:getInstance():addSpriteFrames("images/Big_mahjong_tiles.plist")
	cc.SpriteFrameCache:getInstance():addSpriteFrames("images/Big_mahjonghn_tiles_sr.plist")
    gt.IsBigPai = cc.UserDefault:getInstance():getBoolForKey( "Mj_BigType_Status",false)
	if gt.IsBigPai then
		-- 四人
		gt.MJSprFrame = "p%db%d_%d_big.png"
		gt.MJSprFrameOut = "p%ds%d_%d_big.png"
		gt.SelfMJSprFrame = "p4b%d_%d_big.png"
		gt.SelfMJSprFrameOut = "p4s%d_%d_big.png"

		-- 三人
		gt.SR_MJSprFrame = "sr_p%db%d_%d_big.png"
		gt.SR_MJSprFrameOut = "sr_p%ds%d_%d_big.png"
		gt.SR_SelfMJSprFrame = "sr_p3b%d_%d_big.png"
		gt.SR_SelfMJSprFrameOut = "sr_p3s%d_%d_big.png"
	else
		-- 四人
		gt.MJSprFrame = "p%db%d_%d.png"
		gt.MJSprFrameOut = "p%ds%d_%d.png"
		gt.SelfMJSprFrame = "p4b%d_%d.png"
		gt.SelfMJSprFrameOut = "p4s%d_%d.png"

		-- 三人
		gt.SR_MJSprFrame = "sr_p%db%d_%d.png"
		gt.SR_MJSprFrameOut = "sr_p%ds%d_%d.png"
		gt.SR_SelfMJSprFrame = "sr_p3b%d_%d.png"
		gt.SR_SelfMJSprFrameOut = "sr_p3s%d_%d.png"

	end

	gt.socketClient = require("app/SocketClient"):create()
	
	self.needLoginWXState = 0 -- 本地微信登录状态
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
	
	-- 适配相关
	local csbNode = cc.CSLoader:createNode("Login.csb")
	if display.autoscale == "FIXED_HEIGHT" then
		csbNode:setScale(0.75)
		gt.seekNodeByName(csbNode, "bg"):setScaleY(1280/960)
		gt.seekNodeByName(csbNode, "Node_userName"):setPositionY(-150)
		gt.seekNodeByName(csbNode, "Label_version"):setPositionY(450)
		gt.seekNodeByName(csbNode, "Text_1_1_0"):setPositionY(450)
		gt.seekNodeByName(csbNode, "Text_1"):setPositionY(-440)
		gt.seekNodeByName(csbNode, "Text_1_0"):setPositionY(450)
		gt.seekNodeByName(csbNode, "Node_agreement"):setPositionY(-390)
		gt.seekNodeByName(csbNode, "Btn_phoneLogin"):setPositionY(-300)
		gt.seekNodeByName(csbNode, "Btn_wxLogin"):setPositionY(-300)
	end
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode

	self.autoPhoneLogin = false

	-- 微信登录
	local wxLoginBtn = gt.seekNodeByName(csbNode, "Btn_wxLogin")
	-- 游客输入用户名
	local userNameNode = gt.seekNodeByName(csbNode, "Node_userName")
	local textfield = gt.seekNodeByName(userNameNode, "TxtField_userName")
	-- 手机登录
	local Btn_phoneLogin = gt.seekNodeByName(csbNode, "Btn_phoneLogin")
	gt.addBtnPressedListener(Btn_phoneLogin, function()
		local autoLoginType = cc.UserDefault:getInstance():getStringForKey( "autoLoginType")
		if autoLoginType == "phone" then
			--手机自动登录
			self:checkAutoPhoneLogin()
		else
			if self.VisitorsLogin then
				self.VisitorsLogin:setVisible(true)
				self.VisitorsLogin:setZOrder(65)
			else
				self.VisitorsLogin = require("app/views/VisitorsLogin"):create()
				self:addChild(self.VisitorsLogin,65)
			end
		end
	end)
	-- 游客登录
	local travelerLoginBtn = gt.seekNodeByName(csbNode, "Btn_travelerLogin")
	gt.addBtnPressedListener(travelerLoginBtn, function()
		if not self:checkAgreement() then
			return
		end

		gt.showLoadingTips(gt.getLocationString("LTKey_0003"))
		-- 获取名字
		local openUDID = textfield:getStringValue()
		if string.len(openUDID)==0 then -- 没有填写用户名
			openUDID = cc.UserDefault:getInstance():getStringForKey("openUDID_TIME")
			if string.len(openUDID) == 0 then
				openUDID = tostring(os.time())
				cc.UserDefault:getInstance():setStringForKey("openUDID_TIME", openUDID)
			end
		end

		local nickname = cc.UserDefault:getInstance():getStringForKey("openUDID")
		if string.len(nickname) == 0 then
			nickname = "游客:" .. gt.getRangeRandom(1, 9999)
			cc.UserDefault:getInstance():setStringForKey("openUDID", nickname)
		end
		loginStrategy.ip = gt.TestLoginServer.ip
		gt.socketClient:close()
		gt.socketClient:connect(gt.TestLoginServer.ip, gt.TestLoginServer.port, true)
		local msgToSend = {}
		msgToSend.m_msgId = gt.CG_LOGIN
		msgToSend.m_openId = openUDID
		msgToSend.m_nike = nickname
		msgToSend.m_sign = 123987
		msgToSend.m_plate = "local"
		msgToSend.m_severID = 15001
		gt.unionid = openUDID
		gt.socketClient:setPlayerUUID(openUDID)
		msgToSend.m_uuid = msgToSend.m_openId
		msgToSend.m_sex = 1
		msgToSend.m_nikename = nickname
		msgToSend.m_imageUrl = ""
		gt.socketClient:sendMessage(msgToSend)
		gt.dump(msgToSend)

		-- 保存sex,nikename,headimgurl,uuid,serverid等内容
		cc.UserDefault:getInstance():setStringForKey( "WX_Sex", tostring(1) )
		cc.UserDefault:getInstance():setStringForKey( "WX_Uuid", msgToSend.m_uuid )
		gt.wxNickName = msgToSend.m_nikename
		cc.UserDefault:getInstance():setStringForKey( "WX_ImageUrl", msgToSend.m_imageUrl )
	end)

	-- 判断是否安装微信客户端
	local isWXAppInstalled = false
	if gt.isIOSPlatform() then
		local ok, ret = self.luaBridge.callStaticMethod("AppController", "isWXAppInstalled")
		isWXAppInstalled = ret
	elseif gt.isAndroidPlatform() then
		local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "isWXAppInstalled", nil, "()Z")
		isWXAppInstalled = ret
	end

	if gt.pcLogin then
		travelerLoginBtn:setVisible(true)
		textfield:setVisible(true)
		userNameNode:setVisible(true)
		wxLoginBtn:setVisible(true)
		Btn_phoneLogin:setVisible(true)
	else
		travelerLoginBtn:setVisible(false)
		textfield:setVisible(false)
		userNameNode:setVisible(false)
		wxLoginBtn:setVisible(true)
		Btn_phoneLogin:setVisible(true)
	end
	

	if gt.isIOSPlatform() and gt.isInReview then
		-- 苹果设备在评审状态没有安装微信情况下显示游客登录
		travelerLoginBtn:setVisible(true)
		travelerLoginBtn:setPositionY(-200)
		if display.autoscale == "FIXED_HEIGHT" then
			travelerLoginBtn:setPositionY(-300)
		end
		wxLoginBtn:setVisible(false)
		Btn_phoneLogin:setVisible(true)
		Btn_phoneLogin:setPositionX(0)
	end

	--暂时屏蔽手机注册
	Btn_phoneLogin:setVisible(false)
	wxLoginBtn:setPositionX(0)
	-- 微信登录按钮
	gt.addBtnPressedListener(wxLoginBtn, function()
		if not self:checkAgreement() then
			return
		end

		-- 提示安装微信客户端
		if not isWXAppInstalled and (gt.isAndroidPlatform() or
			(gt.isIOSPlatform() and not gt.isInReview)) then
			-- 安卓一直显示微信登录按钮
			-- 苹果审核通过
			require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0031"), nil, nil, true)
			return
		end

		-- 微信授权登录
		if gt.isIOSPlatform() then
			self.luaBridge.callStaticMethod("AppController", "sendAuthRequest") --startFeedBack
			self.luaBridge.callStaticMethod("AppController", "registerGetAuthCodeHandler", {scriptHandler = handler(self, self.pushWXAuthCode)})
		elseif gt.isAndroidPlatform() then
			self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "sendAuthRequest", nil, "()V")
			self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "registerGetAuthCodeHandler", {handler(self, self.pushWXAuthCode)}, "(I)V")
		end
	end)

	-- 用户协议
	self.agreementChkBox = gt.seekNodeByName(csbNode, "ChkBox_agreement")
	local agreementPanel = gt.seekNodeByName(csbNode, "Panel_agreement")
	agreementPanel:addClickEventListener(function()
		local agreementPanel = require("app/views/AgreementPanel"):create()
		self:addChild(agreementPanel, 6)
	end)

	-- 资源版本号
	local versionLabel = gt.seekNodeByName(csbNode, "Label_version")
	versionLabel:setString(gt.resVersion)

	gt.socketClient:registerMsgListener(gt.GC_LOGIN, self, self.onRcvLogin)
	gt.socketClient:registerMsgListener(gt.GC_LOGIN_GATE, self, self.onRcvLoginGate)
	gt.socketClient:registerMsgListener(gt.GC_LOGIN_SERVER, self, self.onRcvLoginServer)
	gt.socketClient:registerMsgListener(gt.GC_ROOM_CARD, self, self.onRcvRoomCard)
	gt.socketClient:registerMsgListener(gt.GC_MARQUEE, self, self.onRcvMarquee)
	gt.socketClient:registerMsgListener(gt.GC_ACTIVITY_INFO, self, self.onRecvActivityInfo)	
	 
end

--检验手机自动登录
function LoginScene:checkAutoPhoneLogin()
	local nickname = cc.UserDefault:getInstance():getStringForKey( "Phone_Num")
	local sex = cc.UserDefault:getInstance():getStringForKey( "Phone_Sex")
	local Phone_Uuid = cc.UserDefault:getInstance():getStringForKey( "Phone_Uuid")
	if nickname and sex and Phone_Uuid then
		if gt.debugIpGet then
			local VisitorsLogin = require("app/views/VisitorsLogin")
			VisitorsLogin:sendPhoneLogin(gt.TestLoginServer.ip,gt.TestLoginServer.port,nickname,sex,Phone_Uuid)
		else
			self:getHttpServerIpForPhone(Phone_Uuid,nickname,sex)
		end
	end
end

function LoginScene:onNodeEvent(eventName)
	if "enter" == eventName then
		local autoLoginType = cc.UserDefault:getInstance():getStringForKey( "autoLoginType")
		if autoLoginType == "phone" then
			--手机自动登录
			gt.log("手机自动登录"..autoLoginType)
			self:checkAutoPhoneLogin()
		else
			gt.log("微信自动登录"..autoLoginType)
			if gt.localVersion == false and gt.isInReview == false then
				-- 自动登录
				self.autoLoginRet = self:checkAutoLogin()
				if self.autoLoginRet == false then -- 需要重新登录的话,停止转圈
					gt.removeLoadingTips()
				end
			end
		end

		gt.soundEngine:playMusic("bgm1", true)
		-- 触摸事件
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	end
end

function LoginScene:onTouchBegan(touch, event)

	return true
end

function LoginScene:onTouchEnded(touch, event)

end

function LoginScene:unregisterAllMsgListener()
	gt.socketClient:unregisterMsgListener(gt.GC_LOGIN)
	gt.socketClient:unregisterMsgListener(gt.GC_LOGIN_GATE)
	gt.socketClient:unregisterMsgListener(gt.GC_LOGIN_SERVER)
	gt.socketClient:unregisterMsgListener(gt.GC_ROOM_CARD)
	gt.socketClient:unregisterMsgListener(gt.GC_MARQUEE)
	-- gt.socketClient:unregisterMsgListener(gt.GC_ACTIVITY_INFO)
end

--微信自动
function LoginScene:checkAutoLogin()
	-- 转圈
	-- gt.showLoadingTips(gt.getLocationString("LTKey_0003"))

	-- 获取记录中的token,freshtoken时间
	local accessTokenTime  = cc.UserDefault:getInstance():getStringForKey( "WX_Access_Token_Time" )
	local refreshTokenTime = cc.UserDefault:getInstance():getStringForKey( "WX_Refresh_Token_Time" )

	if string.len(accessTokenTime) == 0 or string.len(refreshTokenTime) == 0 then -- 未记录过微信token,freshtoken,说明是第一次登录
		gt.removeLoadingTips()
		return false
	end

	-- 检测是否超时
	local curTime = os.time()
	local accessTokenReconnectTime  = 5400    -- 3600*1.5   微信accesstoken默认有效时间未2小时,这里取1.5,1.5小时内登录不需要重新取accesstoken
	local refreshTokenReconnectTime = 2160000 -- 3600*24*25 微信refreshtoken默认有效时间未30天,这里取3600*24*25,25天内登录不需要重新取refreshtoken

	-- 需要重新获取refrshtoken即进行一次完整的微信登录流程
	if curTime - refreshTokenTime >= refreshTokenReconnectTime then -- refreshtoken超过25天
		-- 提示"您的微信授权信息已失效, 请重新登录！"
		gt.removeLoadingTips()
		require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0030"), nil, nil, true)
		return false
	end

	-- 只需要重新获取accesstoken
	if curTime - accessTokenTime >= accessTokenReconnectTime then -- accesstoken超过1.5小时
		local xhr = cc.XMLHttpRequest:new()
		xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
		local appID;
		if gt.isIOSPlatform() then
			local ok, ret = self.luaBridge.callStaticMethod("AppController", "getAppID")
			appID = ret
		elseif gt.isAndroidPlatform() then
			local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getAppID", nil, "()Ljava/lang/String;")
			appID = ret
		end
		local refreshTokenURL = string.format("https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%s&grant_type=refresh_token&refresh_token=%s", appID, cc.UserDefault:getInstance():getStringForKey( "WX_Refresh_Token" ))
		xhr:open("GET", refreshTokenURL)
		local function onResp()
			gt.log("xhr.readyState is:" .. xhr.readyState .. " xhr.status is: " .. xhr.status)
			gt.removeLoadingTips()
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
				local response = xhr.response
				require("json")
				local respJson = json.decode(response)
				if respJson.errcode then
					-- 申请失败,清除accessToken,refreshToken等信息
					cc.UserDefault:getInstance():setStringForKey("WX_Access_Token", "")
					cc.UserDefault:getInstance():setStringForKey("WX_Refresh_Token", "")
					cc.UserDefault:getInstance():setStringForKey("WX_Access_Token_Time", "")
					cc.UserDefault:getInstance():setStringForKey("WX_Refresh_Token_Time", "")
					cc.UserDefault:getInstance():setStringForKey("WX_OpenId", "")

					-- 清理掉圈圈
					gt.removeLoadingTips()
					self.autoLoginRet = false

				else

					self.needLoginWXState = 2 -- 需要更新accesstoken以及其时间

					local accessToken = respJson.access_token
					local refreshToken = respJson.refresh_token
					local openid = respJson.openid
					self:loginServerWeChat(accessToken, refreshToken, openid)

				end
			elseif xhr.readyState == 1 and xhr.status == 0 then
				-- 本地网络连接断开

				-- cc.UserDefault:getInstance():setStringForKey("WX_Access_Token", "")
				-- cc.UserDefault:getInstance():setStringForKey("WX_Refresh_Token", "")
				-- cc.UserDefault:getInstance():setStringForKey("WX_Access_Token_Time", "")
				-- cc.UserDefault:getInstance():setStringForKey("WX_Refresh_Token_Time", "")
				-- cc.UserDefault:getInstance():setStringForKey("WX_OpenId", "")

				gt.removeLoadingTips()
				self.autoLoginRet = false
				-- require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)
				
				-- 在走一次自动登录
				self:errCheckAutoLogin()

			end
			xhr:unregisterScriptHandler()
		end
		xhr:registerScriptHandler(onResp)
		xhr:send()

		return true
	end

	-- accesstoken未过期,freshtoken未过期 则直接登录即可
	self.needLoginWXState = 1

	local accessToken 	= cc.UserDefault:getInstance():getStringForKey( "WX_Access_Token" )
	local refreshToken 	= cc.UserDefault:getInstance():getStringForKey( "WX_Refresh_Token" )
	local openid 		= cc.UserDefault:getInstance():getStringForKey( "WX_OpenId" )

	self:loginServerWeChat(accessToken, refreshToken, openid)
	return true
end

function LoginScene:onRcvLogin(msgTbl)

	gt.dump(msgTbl)
	if msgTbl.m_errorCode == 0 then
		local autoLoginType = msgTbl.m_plate
		cc.UserDefault:getInstance():setStringForKey( "autoLoginType", autoLoginType)
	end
	-- 如果有进入此函数则说明token,refreshtoken,openid是有效的,可以记录.
	if self.needLoginWXState == 0 then
		-- 重新登录,因此需要全部保存一次
		cc.UserDefault:getInstance():setStringForKey( "WX_Access_Token", self.m_accessToken )
		cc.UserDefault:getInstance():setStringForKey( "WX_Refresh_Token", self.m_refreshToken )
		cc.UserDefault:getInstance():setStringForKey( "WX_OpenId", self.m_openid )

		cc.UserDefault:getInstance():setStringForKey( "WX_Access_Token_Time", os.time() )
		cc.UserDefault:getInstance():setStringForKey( "WX_Refresh_Token_Time", os.time() )
	elseif self.needLoginWXState == 1 then
		-- 无需更改
		-- ...
	elseif self.needLoginWXState == 2 then
		-- 需更改accesstoken
		cc.UserDefault:getInstance():setStringForKey( "WX_Access_Token", self.m_accessToken )
		cc.UserDefault:getInstance():setStringForKey( "WX_Access_Token_Time", os.time() )
	end


	gt.loginSeed = msgTbl.m_seed
	gt.m_id = msgTbl.m_id

	gt.GateServer.port = tostring(msgTbl.m_gatePort)

	if msgTbl.m_totalPlayNum ~= nil then
		gt.totalPlayNum = msgTbl.m_totalPlayNum
		loginStrategy:savePlayCount(msgTbl.m_totalPlayNum)
		-- gt.log("onRcvLogin playCount = " .. self:getPlayCount())
	else
		-- gt.log("onRcvLogin playCount = nil")
	end

	-- loginStrategy.ip = "192.168.10.141"
	gt.socketClient:close()
	gt.socketClient:connect(loginStrategy.ip, gt.GateServer.port, true)
	local msgToSend = {}
	msgToSend.m_msgId = gt.CG_LOGIN_GATE
	msgToSend.m_strUserUUID = gt.socketClient:getPlayerUUID()
	gt.socketClient:sendMessage(msgToSend)
	gt.dump(msgToSend)
end

--服务器返回gate登录
function LoginScene:onRcvLoginGate( msgTbl )
	
	dump( msgTbl )

	gt.socketClient:setPlayerKeyAndOrder(msgTbl.m_strKey, msgTbl.m_uMsgOrder)

	local msgToSend = {}
	msgToSend.m_msgId = gt.CG_LOGIN_SERVER
	msgToSend.m_seed = gt.loginSeed
	msgToSend.m_id = gt.m_id
	local catStr = tostring(gt.loginSeed)
	msgToSend.m_md5 = cc.UtilityExtension:generateMD5(catStr, string.len(catStr))
	gt.dump(msgToSend)
	gt.socketClient:sendMessage(msgToSend)
end

-- start --
--------------------------------
-- @class function
-- @description 服务器返回登录大厅结果
-- end --
function LoginScene:onRcvLoginServer(msgTbl)

	dump(msgTbl)

	if buglyReportLuaException and not gt.debugMode then
		print("bugly 测试：",msgTbl.m_id)
		buglySetUserId(msgTbl.m_id)
	end
	
	-- 去掉转圈
	gt.removeLoadingTips()

	-- 取消登录超时弹出提示
	self.rootNode:stopAllActions()

	-- 登录成功后 设置开始游戏状态
	gt.socketClient:setIsStartGame(true)
	gt.socketClient:setIsCloseHeartBeat(false)

	-- 购买房卡可变信息
	gt.roomCardBuyInfo = msgTbl.m_buyInfo

	-- 是否是gm 0不是  1是
	gt.isGM = msgTbl.m_gm
	--是否是老玩家 1 是 其它不是
	gt.IsOldUser = msgTbl.m_oldUser

	-- 玩家信息
	local playerData = gt.playerData
	playerData.uid = msgTbl.m_id
	playerData.nickname = msgTbl.m_nike
	playerData.exp = msgTbl.m_exp
	playerData.sex = msgTbl.m_sex
	-- 下载小头像url
	playerData.headURL = string.sub(msgTbl.m_face, 1, string.lastString(msgTbl.m_face, "/")) .. "96"
	playerData.ip = msgTbl.m_ip

	-- 登录呀呀云语音sdk
	if gt.isUseNewMusic() == true then
		if gt.isIOSPlatform() then
			local ok = self.luaBridge.callStaticMethod("AppController", "loginYayaSDK", 
				{username = playerData.uid,userid = playerData.uid})
		end
	end
	
	-- 判断进入大厅还是房间
	if msgTbl.m_state == 1 then
		-- 等待进入房间消息
		gt.socketClient:registerMsgListener(gt.GC_ENTER_ROOM, self, self.onRcvEnterRoom)
	else
		gt.removeTargetAllEventListener(self)
		self:unregisterAllMsgListener()

		-- 进入大厅主场景
		-- 判断是否是新玩家
		local isNewPlayer = msgTbl.m_new == 0 and true or false
		local showCardInfo = {}
		if msgTbl.m_loginInterval then
			showCardInfo.loginInterval = msgTbl.m_loginInterval
			showCardInfo.m_card1 = msgTbl.m_card1
		end
		
		local mainScene = require("app/views/MainScene"):create(isNewPlayer, nil, nil, showCardInfo)
		cc.Director:getInstance():replaceScene(mainScene)
	end
end

-- start --
--------------------------------
-- @class function
-- @description 接收房卡信息
-- @param msgTbl 消息体
-- end --
function LoginScene:onRcvRoomCard(msgTbl)
	dump(msgTbl)
	local playerData = gt.playerData
	playerData.roomCardsCount = {msgTbl.m_card1, msgTbl.m_card2, msgTbl.m_card3,msgTbl.m_coins}
	playerData.m_credit = msgTbl.m_credit
	if gt.isInReview == true then
		playerData.m_credit = 0
	end
end

-- start --
--------------------------------
-- @class function
-- @description 接收通用的活动内容
-- @param msgTbl 消息体
-- end --
function LoginScene:onRecvActivityInfo( msgTbl )
	gt.log("通用活动内容")
	dump(msgTbl)

	if gt.isInReview then
		return
	end
	require("json")
	for i=1,#msgTbl.m_activities do
		if msgTbl.m_activities[i][1] == 1003 then
			gt.log("msgTbl.m_activities[i][3][1][2] = "..msgTbl.m_activities[i][3][1][2])
			local respJson = json.decode(msgTbl.m_activities[i][2])
			gt.ShareString = respJson.Desc
			gt.log("gt.ShareString = "..gt.ShareString)
			--分享送房卡
			if msgTbl.m_activities[i][3][1][2] == "1" then
				gt.m_IsShare = 1
				gt.log("gt.m_IsShare = "..gt.m_IsShare)
			elseif msgTbl.m_activities[i][3][1][2] == "0" then
				gt.m_IsShare = 2
			end
			gt.m_shareActivityStatus = true
		elseif msgTbl.m_activities[i][1] == 1002 then
			--转盘活动
			gt.m_activeID = 1002
			local beginTime = os.date("*t", msgTbl.m_activities[i][3][1][2])
			beginTime = beginTime.year .. "年" .. beginTime.month .. "月" .. beginTime.day .. "日 " .. beginTime.hour .. ":" .. beginTime.min
			local EndTime = os.date("*t", msgTbl.m_activities[i][3][2][2])
			EndTime = EndTime.year .. "年" .. EndTime.month .. "月" .. EndTime.day .. "日 " .. EndTime.hour .. ":" .. EndTime.min
			gt.GoldTime = "活动时间：" .. beginTime  .. "至" .. EndTime
			gt.log(gt.GoldTime)
		elseif msgTbl.m_activities[i][1] == 1004 then
			-- 邀请好友活动
			gt.m_activeID = 1004
			gt.m_inviteActivityStatus = true
		elseif msgTbl.m_activities[i][1] == 1005 then		
			gt.m_activeID = 1005
			gt.m_dragonBoatActivityStatus = true
			local attriVector = msgTbl.m_activities[i][3] or {}
			gt.m_dragonBoatActivityPointNum = 0
			for _key,_value in ipairs(attriVector) do
				local attriName = _value[1]
				if attriName == "FD" then
					gt.m_dragonBoatActivityPointNum = _value[2]
				end
			end
			gt.m_dragonBoatActivityPointNum = gt.m_dragonBoatActivityPointNum or 0
		end
	end
end

-- start --
--------------------------------
-- @class function
-- @description 接收跑马灯消息
-- @param msgTbl 消息体
-- end --
function LoginScene:onRcvMarquee(msgTbl)

	gt.log("限时活动balabala")
	dump(msgTbl)

	-- 暂存跑马灯消息,切换到主场景之后显示
	if gt.isIOSPlatform() and gt.isInReview then
		gt.marqueeMsgTemp = gt.getLocationString("LTKey_0048")
	else
		if msgTbl.m_type == 0 then
            -- 已经改用分IP新的跑马灯
		elseif msgTbl.m_type == 1 then

			gt.FreeGameType = {}
			require("json")
			gt.log("string.len(msgTbl.m_str) = "..string.len(msgTbl.m_str))
			if string.len(msgTbl.m_str)>0 then
				local respJson = json.decode(msgTbl.m_str)
				gt.dump(respJson)
				if respJson ~= nil and #respJson >0 then
					for i,v in ipairs(respJson) do
						gt.dump(v)
						if v.GameType == "All" then
							gt.FreeGameType = gt.AllGameType
						else
							table.insert(gt.FreeGameType,tonumber(v.GameType))
						end
					end
				else
					gt.FreeGameType = {}
				end
			end
			table.sort(gt.FreeGameType)
			if #gt.FreeGameType > 2 then
				for i=2,#gt.FreeGameType do
					if gt.FreeGameType[i] == gt.FreeGameType[i-1] then
						table.remove(gt.FreeGameType,i-1)
					end
				end
			end
			gt.dump(gt.FreeGameType)
		elseif msgTbl.m_type == 2 then
			if string.len(msgTbl.m_str) > 1 then
				gt.IsExchangeGoldActShow = true
				require("json")
   				local respJson = json.decode(msgTbl.m_str)
   				local beginTime = os.date("*t", respJson.StartTime)
   				beginTime = beginTime.year .. "年" .. beginTime.month .. "月" .. beginTime.day .. "日 " .. beginTime.hour .. ":" .. beginTime.min
   				local EndTime = os.date("*t", respJson.EndTime)
   				EndTime = EndTime.year .. "年" .. EndTime.month .. "月" .. EndTime.day .. "日 " .. EndTime.hour .. ":" .. EndTime.min
				gt.GoldTime = "活动时间：" .. beginTime  .. "至" .. EndTime
				gt.log(gt.GoldTime)
			else
				gt.IsExchangeGoldActShow = false
			end
		end
	end
end

--进入房间
function LoginScene:onRcvEnterRoom(msgTbl)
	self:unregisterAllMsgListener()
	gt.CopyText(" ")
	gt.roomState = tonumber(msgTbl.m_state)
	gt.report_desk_id = tonumber(msgTbl.m_deskId)
	if tonumber(msgTbl.m_state) == 102 then
		local playScene = require("app/views/PlaySceneXL"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	elseif tonumber(msgTbl.m_state) == 101 then
		local playScene = require("app/views/PlaySceneXZ"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	elseif tonumber(msgTbl.m_state) == 103 then
		local playScene = require("app/views/PlaySceneTX"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	elseif tonumber(msgTbl.m_state) == 104 then
		local playScene = require("app/views/PlaySceneDDH"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	elseif tonumber(msgTbl.m_state) == 105 then
		local playScene = require("app/views/PlaySceneNJ"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	elseif tonumber(msgTbl.m_state) == 106 then
		local playScene = require("app/views/PlaySceneDY"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	elseif tonumber(msgTbl.m_state) == 107 then
		local playScene = require("app/views/PlaySceneTXS"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	elseif tonumber(msgTbl.m_state) == 108 then--绵阳麻将
		local playScene = require("app/views/PlaySceneMY"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	elseif tonumber(msgTbl.m_state) == 109 then--宜宾麻将
		local playScene = require("app/views/PlaySceneYB"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	elseif tonumber(msgTbl.m_state) == 110 then--万州麻将
		local playScene = require("app/views/PlaySceneWZ"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	elseif tonumber(msgTbl.m_state) == 111 then--泸州麻将
		local playScene = require("app/views/PlaySceneLZ"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	elseif tonumber(msgTbl.m_state) == 112 then--泸州麻将
		local playScene = require("app/views/PlaySceneLS"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	elseif tonumber(msgTbl.m_state) == 113 then--南充麻将
		local playScene = require("app/views/PlaySceneNC"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	elseif tonumber(msgTbl.m_state) == 116 then--雅安麻将
		local playScene = require("app/views/PlaySceneYA"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	elseif tonumber(msgTbl.m_state) == 115 then--自贡麻将
		local playScene = require("app/views/PlaySceneZG"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	elseif tonumber(msgTbl.m_state) == 117 then--自贡四人麻将
		local playScene = require("app/views/PlaySceneZGSR"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	elseif tonumber(msgTbl.m_state) == 114 then--广安麻将
		local playScene = require("app/views/PlaySceneGA"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
    elseif tonumber(msgTbl.m_state) == 118 then -- 内江三人
		local playScene = require("app/views/PlaySceneNeiJiang"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
    elseif tonumber(msgTbl.m_state) == 119 then -- 内江四人
		local playScene = require("app/views/PlaySceneNeiJiang"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
    elseif tonumber(msgTbl.m_state) == 120 then -- 两人麻将
		local playScene = require("app/views/PlaySceneErRen"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	elseif tonumber(msgTbl.m_state) == 1102 then--金币场
		local playScene = require("app/views/PlaySceneGold"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	elseif tonumber(msgTbl.m_state) == 1101 then--比赛场
		local playScene = require("app/views/PlaySceneMatch"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	end
end

--微信登录调用函数
function LoginScene:pushWXAuthCode(authCode)

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local appID;
	if gt.isIOSPlatform() then
		local ok, ret = self.luaBridge.callStaticMethod("AppController", "getAppID")
		appID = ret
	elseif gt.isAndroidPlatform() then
		local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getAppID", nil, "()Ljava/lang/String;")
		appID = ret
	end
	local secret = "a08740b80d37016355fdec8cd4cc089d"
	-- android换个微信的appsecret  
	if gt.isAndroidPlatform() then
		if gt.LastVersionNum() > 3 then
			secret = "2d6ea71674fc61cba525c0bc0f5c339f"
		end
	elseif gt.isIOSPlatform() then
		if gt.checkVersion(1, 0, 4) then
			local ok, ret = self.luaBridge.callStaticMethod("AppController", "getBundleID")
			if ret == "com.majiang.scxm" then
				secret = "c444387b86618989e856e7071d28fcd3"
			elseif ret == "com.sichuan.majiangxmjh" then 	--最新版本
				secret = "3bc791b537f60a6ca8a8c54312562b4e"
			elseif ret == "com.game.sichuan" then 	--最新版本 1.0.7
				secret = "2d6ea71674fc61cba525c0bc0f5c339f"
				if gt.LastVersionNum() == 10 then
					secret = "3bc791b537f60a6ca8a8c54312562b4e"
				end
			elseif ret == "com.game.xiongmao" then
				secret = "3bc791b537f60a6ca8a8c54312562b4e"
			end
		else
			if appID == "wx01862222f922d138" then --老版APPstore版本
				secret = "a08740b80d37016355fdec8cd4cc089d"
			elseif appID == "wx848c15b329e26e8d" then 	--企业签名包
				secret = "284ee9ce1f70dc971241410cc75c9627"
			end
		end
	end

	local accessTokenURL = string.format("https://api.weixin.qq.com/sns/oauth2/access_token?appid=%s&secret=%s&code=%s&grant_type=authorization_code", appID, secret, authCode)
	xhr:open("GET", accessTokenURL)
	local function onResp()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local response = xhr.response
			require("json")
			local respJson = json.decode(response)
			if respJson.errcode then
				-- 申请失败
				require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0030"), nil, nil, true)
				gt.removeLoadingTips()
				self.autoLoginRet = false
			else
				local accessToken = respJson.access_token
				local refreshToken = respJson.refresh_token
				local openid = respJson.openid

				self:loginServerWeChat(accessToken, refreshToken, openid)
			end
		elseif xhr.readyState == 1 and xhr.status == 0 then
			-- 本地网络连接断开
			gt.removeLoadingTips()
			self.autoLoginRet = false

			-- 切换微信授权的域名变为ip再次授权一次
			self:errPushWXAuthCode(authCode)
			-- require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end

-- 此函数可以去微信请求个人 昵称,性别,头像url等内容
function LoginScene:requestUserInfo(accessToken, refreshToken, openid)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	if not self.errorIP then
		self.errorIP = "api.weixin.qq.com"
	end
	local userInfoURL = string.format("https://"..self.errorIP.."/sns/userinfo?access_token=%s&openid=%s", accessToken, openid)
	xhr:open("GET", userInfoURL)
	local function onResp()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local response = xhr.response
			require("json")
			response = string.gsub(response,"\\","")
			response = self:godNick(response)
			local respJson = json.decode(response)
			dump(respJson)
			if respJson.errcode then
				require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0030"))
				gt.removeLoadingTips()
				self.autoLoginRet = false
				
			else
				local sex 			= respJson.sex
				local nickname 		= respJson.nickname
				local headimgurl 	= respJson.headimgurl
				local unionid 		= respJson.unionid

				if buglyReportLuaException and not gt.debugMode then
					-- buglySetTag(1)
					buglyAddUserValue("sex",tostring(sex) or "")
					buglyAddUserValue("nickname",tostring(nickname) or "")
					buglyAddUserValue("headimgurl",tostring(headimgurl) or "")
					buglyAddUserValue("unionid",tostring(unionid) or "")
					buglyAddUserValue("accessToken",tostring(accessToken) or "")
					buglyAddUserValue("refreshToken",tostring(refreshToken) or "")
					buglyAddUserValue("openid",tostring(openid) or "")
					buglyAddUserValue("游戏本地版本",tostring(cc.exports.gt.resVersion) or "")
					buglyAddUserValue("是否第一次更新",tostring(cc.exports.gt.isUpdate) or "")
				else
					gt.log("buglyReportLuaException 为空")
				end

				-- 记录一下相关数据
				self.accessToken 	= accessToken
				self.refreshToken 	= refreshToken
				self.openid 		= openid
				self.sex 			= sex
				self.nickname 		= nickname
				self.headimgurl 	= headimgurl
				self.unionid 		= unionid
				gt.unionid = unionid

				gt.socketClient:setPlayerUUID(unionid)

				-- 测试模式走测试服务器
				if gt.debugIpGet then
					self:sendRealLogin(gt.TestLoginServer.ip,gt.TestLoginServer.port, accessToken, refreshToken, openid, sex, nickname, headimgurl, unionid)
				else
					self:getHttpServerIp(unionid)
					--读取上次成功的本地IP
					-- gt.LoginSuccessIp = cc.UserDefault:getInstance():getStringForKey("LoginSuccessIp")
					-- if string.len(gt.LoginSuccessIp) ==  0 then
					-- 	self:getHttpServerIp(unionid)--为空走ip策略
					-- else
					-- 	gt.log("读取gt.LoginSuccessIp = "..gt.LoginSuccessIp)
					-- 	local errorCode = gt.socketClient:connect(gt.LoginSuccessIp, gt.LoginServer.port, true)
					-- 	if errorCode == true then
					-- 		loginStrategy.ip = gt.LoginSuccessIp
					-- 		--保存本地
					-- 		cc.UserDefault:getInstance():setStringForKey("LoginSuccessIp", loginStrategy.ip)

					-- 		gt.resume_time = 30

					-- 		local msgToSend = {}
					-- 		msgToSend.m_msgId = gt.CG_LOGIN
					-- 		msgToSend.m_plate = "wechat"
					-- 		msgToSend.m_accessToken = accessToken
					-- 		msgToSend.m_refreshToken = refreshToken
					-- 		msgToSend.m_openId = openid
					-- 		msgToSend.m_severID = 15001
					-- 		msgToSend.m_sex = tonumber(sex)
					-- 		msgToSend.m_nikename = nickname
					-- 		msgToSend.m_imageUrl = headimgurl
					-- 		msgToSend.m_uuid = unionid

					-- 		cc.UserDefault:getInstance():setStringForKey( "WX_Sex", tostring(sex) )
					-- 		cc.UserDefault:getInstance():setStringForKey( "WX_Uuid", unionid )
					-- 		gt.wxNickName = nickname
					-- 		cc.UserDefault:getInstance():setStringForKey( "WX_ImageUrl", self.headimgurl )


					-- 		local catStr = string.format("%s%s%s%s", openid, accessToken, refreshToken,unionid)
					-- 		msgToSend.m_md5 = cc.UtilityExtension:generateMD5(catStr, string.len(catStr))
					-- 		gt.socketClient:sendMessage(msgToSend)
					-- 	else
					-- 		self:getHttpServerIp(unionid)
					-- 		-- loginStrategy:getCdnIp()
					-- 	end
					-- end
				end

			end

		elseif xhr.readyState == 1 and xhr.status == 0 then
			-- 本地网络连接断开
			-- require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)
			gt.removeLoadingTips()
			self.autoLoginRet = false

			self:errRequestUserInfo(self.m_accessToken,self.m_refreshToken,self.m_openid)
				
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end

--登录login
function LoginScene:sendRealLogin(ip,port,accessToken, refreshToken, openid, sex, nickname, headimgurl, unionid )
	gt.showLoadingTips(gt.getLocationString("LTKey_0003"))

	-- 记录当前的ip   
	loginStrategy.ip = ip

	gt.socketClient:close()
	local errorCode = gt.socketClient:connect(ip, port, true)
	if errorCode == true then
		--保存本地
		cc.UserDefault:getInstance():setStringForKey("LoginSuccessIp", ip)
		gt.log("写入gt.LoginSuccessIp = "..ip)
		gt.resume_time = 30

		local msgToSend = {}
		msgToSend.m_msgId = gt.CG_LOGIN
		msgToSend.m_plate = "wechat"
		msgToSend.m_accessToken = accessToken
		msgToSend.m_refreshToken = refreshToken
		msgToSend.m_openId = openid
		msgToSend.m_severID = 15001
		msgToSend.m_sex = tonumber(sex)
		msgToSend.m_nikename = nickname
		msgToSend.m_imageUrl = headimgurl
		msgToSend.m_uuid = unionid

		cc.UserDefault:getInstance():setStringForKey( "WX_Sex", tostring(sex) )
		cc.UserDefault:getInstance():setStringForKey( "WX_Uuid", unionid )
		gt.wxNickName = nickname
		cc.UserDefault:getInstance():setStringForKey( "WX_ImageUrl", self.headimgurl )


		local catStr = string.format("%s%s%s%s", openid, accessToken, refreshToken,unionid)
		msgToSend.m_md5 = cc.UtilityExtension:generateMD5(catStr, string.len(catStr))
		gt.socketClient:sendMessage(msgToSend)
		gt.dump(msgToSend)
	else
		--读取上次成功的本地IP
		gt.LoginSuccessIp = cc.UserDefault:getInstance():getStringForKey("LoginSuccessIp")
		if string.len(gt.LoginSuccessIp) ==  0 then
			loginStrategy.ip = ip
			loginStrategy.port = port
			loginStrategy:getIpByIpServer()--为空走ip策略
		else
			gt.log("读取gt.LoginSuccessIp = "..gt.LoginSuccessIp)
			local errorCode = gt.socketClient:connect(gt.LoginSuccessIp, port, true)
			if errorCode == true then
				loginStrategy.ip = gt.LoginSuccessIp
				--保存本地
				cc.UserDefault:getInstance():setStringForKey("LoginSuccessIp", loginStrategy.ip)

				gt.resume_time = 30

				local msgToSend = {}
				msgToSend.m_msgId = gt.CG_LOGIN
				msgToSend.m_plate = "wechat"
				msgToSend.m_accessToken = accessToken
				msgToSend.m_refreshToken = refreshToken
				msgToSend.m_openId = openid
				msgToSend.m_severID = 15001
				msgToSend.m_sex = tonumber(sex)
				msgToSend.m_nikename = nickname
				msgToSend.m_imageUrl = headimgurl
				msgToSend.m_uuid = unionid

				cc.UserDefault:getInstance():setStringForKey( "WX_Sex", tostring(sex) )
				cc.UserDefault:getInstance():setStringForKey( "WX_Uuid", unionid )
				gt.wxNickName = nickname
				cc.UserDefault:getInstance():setStringForKey( "WX_ImageUrl", self.headimgurl )

				local catStr = string.format("%s%s%s%s", openid, accessToken, refreshToken,unionid)
				msgToSend.m_md5 = cc.UtilityExtension:generateMD5(catStr, string.len(catStr))
				gt.socketClient:sendMessage(msgToSend)
			else
				loginStrategy.ip = ip
				loginStrategy.port = port
				loginStrategy:getIpByIpServer()
			end
		end
	end
end

-- 断线重连,走一次登录流程
function LoginScene:reLogin()
	gt.resume_time = 30

	local msgToSend = {}
	msgToSend.m_msgId = gt.CG_LOGIN
	msgToSend.m_plate = "wechat"
	msgToSend.m_accessToken = self.accessToken
	msgToSend.m_refreshToken = self.refreshToken
	msgToSend.m_openId = self.openid
	msgToSend.m_severID = 15001
	msgToSend.m_uuid = self.unionid
	msgToSend.m_sex = tonumber(self.sex)
	msgToSend.m_nikename = self.nickname
	msgToSend.m_imageUrl = self.headimgurl

	cc.UserDefault:getInstance():setStringForKey( "WX_Sex", tostring(self.sex) )
	cc.UserDefault:getInstance():setStringForKey( "WX_Uuid", self.unionid )
	gt.wxNickName = self.nickname
	cc.UserDefault:getInstance():setStringForKey( "WX_ImageUrl", self.headimgurl )

	local catStr = string.format("%s%s%s%s", self.openid, self.accessToken, self.refreshToken, self.unionid)
	msgToSend.m_md5 = cc.UtilityExtension:generateMD5(catStr, string.len(catStr))
	gt.socketClient:sendMessage(msgToSend)

end

--ips策略
function LoginScene:getHttpServerIp(uuid)
	-- local servername = "sichuan"
	-- local srcSign = string.format("%s%s", uuid, servername)
	-- local sign = cc.UtilityExtension:generateMD5(srcSign, string.len(srcSign))
	-- local xhr = cc.XMLHttpRequest:new()
	-- self.xhr_un = xhr
	-- xhr.timeout = 3

	-- self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.erripserverhandler), 3, false)

	-- xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	-- -- xhr:setTimeout(2)
	-- --secureapisichuan.ixianlai.com 新的ip策略地址  --secureapi.ixianlai.com  旧的ip策略地址
	-- local refreshTokenURL = string.format("http://secureapisichuan.ixianlai.com/security/server/getIPbyZoneUid")
	-- xhr:open("POST", refreshTokenURL)
	-- local function onResp()
	-- 	if self.scheduleHandler then
	-- 		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
	-- 		self.scheduleHandler = nil
	-- 	end
	-- 	gt.log("xhr.readyState = " .. xhr.readyState .. ", xhr.status = " .. xhr.status)
	-- 	gt.log("xhr.statusText = " .. xhr.statusText)
	-- 	if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
	-- 		local response = xhr.response
	-- 		dump(response)
	-- 		require("json")
	-- 		local respJson = json.decode(response)
			
	-- 		if respJson.errorCode == 0 then 

	-- 			self:sendRealLogin(respJson.ip,gt.LoginServer.port,self.accessToken, self.refreshToken, self.openid, self.sex, self.nickname, self.headimgurl, self.unionid)
	-- 		else
	-- 			-- 第一次登录重连
	-- 			gt.socketClient:reloginServer()
	-- 		end
	-- 	elseif xhr.readyState == 1 and xhr.status == 0 then
			
	-- 		gt.socketClient:reloginServer()

	-- 	end
	-- 	xhr:unregisterScriptHandler()
	-- end
	-- xhr:registerScriptHandler(onResp)
	-- gt.log(string.format("uuid=%s&servername=%s&sign=%s", uuid, servername, sign))
	-- xhr:send(string.format("uuid=%s&servername=%s&sign=%s", uuid, servername, sign))
	-- gt.transitIP = "192.168.10.87"
	gt.log("直接连固定IP"..gt.transitIP)
	self:sendRealLogin(gt.transitIP,gt.LoginServer.port,self.accessToken, self.refreshToken, self.openid, self.sex, self.nickname, self.headimgurl, self.unionid)
end

function LoginScene:getHttpServerIpForPhone(uuid,nickname,sex)
	local servername = "sichuan"
	local srcSign = string.format("%s%s", uuid, servername)
	local sign = cc.UtilityExtension:generateMD5(srcSign, string.len(srcSign))
	local xhr = cc.XMLHttpRequest:new()
	xhr.timeout = 5
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local refreshTokenURL = string.format("http://secureapisichuan.ixianlai.com/security/server/getIPbyZoneUid")
	xhr:open("POST", refreshTokenURL)
	local function onResp()
		gt.log("xhr.readyState = " .. xhr.readyState .. ", xhr.status = " .. xhr.status)
		gt.log("xhr.statusText = " .. xhr.statusText)
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local response = xhr.response
			dump(response)
			require("json")
			local respJson = json.decode(response)
			if respJson.errorCode == 0 then 
				local VisitorsLogin = require("app/views/VisitorsLogin")
				VisitorsLogin:sendPhoneLogin(respJson.ip,gt.TestLoginServer.port,nickname,sex,uuid)
				-- self:sendRealLogin(respJson.ip,gt.LoginServer.port,self.accessToken, self.refreshToken, self.openid, self.sex, self.nickname, self.headimgurl, self.unionid)
			else
				-- 第一次登录重连
				gt.socketClient:reloginServer()
			end
		elseif xhr.readyState == 1 and xhr.status == 0 then
			
			gt.socketClient:reloginServer()

		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send(string.format("uuid=%s&servername=%s&sign=%s", uuid, servername, sign))
end

--验证token
function LoginScene:loginServerWeChat(accessToken, refreshToken, openid)
	-- 保存下token相关信息,若验证通过,存储到本地
	self.m_accessToken 	= accessToken
	self.m_refreshToken = refreshToken
	self.m_openid 		= openid
	-- 请求昵称,头像等信息
	gt.showLoadingTips(gt.getLocationString("LTKey_0003"))
	self:requestUserInfo( accessToken, refreshToken, openid )

end

--协议
function LoginScene:checkAgreement()
	if not self.agreementChkBox:isSelected() then
		require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0041"), nil, nil, true)
		return false
	end
	return true
end

--更新提示以及公告
function LoginScene:updateAppVersion()
	-- body
	print("appVersionUpdateFinish..........")

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local accessTokenURL = "http://www.ixianlai.com/updateInfo.php"
	xhr:open("GET", accessTokenURL)
	local function onResp()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local response = xhr.response

			require("json")
			local respJson = json.decode(response)
			local Version = respJson.Version
			local State = respJson.State
			local msg = respJson.msg

			gt.log("the update version is :" .. Version)

			local ok, appVersion = nil
			if gt.isIOSPlatform() then
				ok, appVersion = self.luaBridge.callStaticMethod("AppController", "getVersionName")
			elseif gt.isAndroidPlatform() then
				ok, appVersion = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getAppVersionName", nil, "()Ljava/lang/String;")
			end

			gt.log("the appVersion is :" .. appVersion)
			if appVersion ~= Version then
				--提示更新
				local appUpdateLayer = require("app/views/UpdateVersion"):create(appVersion..msg,State)
  	 			self:addChild(appUpdateLayer, 100)
			end

		elseif xhr.readyState == 1 and xhr.status == 0 then
			-- 本地网络连接断开
			require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)

		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()

end

--解析nickname
function LoginScene:godNick(text)
	local s = string.find(text, "\"nickname\":\"")
	if not s then
		return text
	end
	local e = string.find(text, "\",\"sex\"")
	local n = string.sub(text, s + 12, e - 1)
	local m = string.gsub(n, '"', '\\\"')
	local i = string.sub(text, 0, s + 11)
	local j = string.sub(text, e, string.len(text))
	return i .. m .. j
end
--ios充值初始化
function LoginScene:initPurchaseInfo()
	if gt.checkIAPState() == true then
		require("app/views/Purchase/init")
		require("app/views/Purchase/Charge")
		local productConfig = gt.getRechargeConfig()
		local productsInfo = ""
		if #productConfig > 0 then
			for i = 1, #productConfig do
				local tmpProduct = productConfig[i]
				local productId = tmpProduct["AppStore"]
				productsInfo = productsInfo .. productId .. ","
			end
			local luaBridge = require("cocos/cocos2d/luaoc")
			luaBridge.callStaticMethod("AppController", "initPaymentInfo", {paymentInfo = productsInfo})

			gt.sdkBridge.init()
		end
	end
end
--ips超时处理
function LoginScene:erripserverhandler(delta)
	gt.log("function is erripserverhandler")
	self.xhr_un:unregisterScriptHandler()
	-- 请求失败  
	gt.removeLoadingTips()
	loginStrategy.loginStateType = loginStrategy.state.ERROR
	loginStrategy.port = gt.LoginServer.port
	loginStrategy:getIpGaoFang()
	if self.scheduleHandler then
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
		self.scheduleHandler = nil
	end
end

---------------------------微信授权失败后再次调用的函数-------------------

function LoginScene:errPushWXAuthCode(authCode)

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local appID;
	if gt.isIOSPlatform() then
		local ok, ret = self.luaBridge.callStaticMethod("AppController", "getAppID")
		appID = ret
	elseif gt.isAndroidPlatform() then
		local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getAppID", nil, "()Ljava/lang/String;")
		appID = ret
	end
	local secret = "a08740b80d37016355fdec8cd4cc089d"
	-- android换个微信的appsecret  
	if gt.isAndroidPlatform() then
		if gt.LastVersionNum() > 3 then
			secret = "2d6ea71674fc61cba525c0bc0f5c339f"
		end
	elseif gt.isIOSPlatform() then
		if gt.checkVersion(1, 0, 4) then
			local ok, ret = self.luaBridge.callStaticMethod("AppController", "getBundleID")
			if ret == "com.majiang.scxm" then
				secret = "c444387b86618989e856e7071d28fcd3"
			elseif ret == "com.sichuan.majiangxmjh" then 	--最新版本
				secret = "3bc791b537f60a6ca8a8c54312562b4e"
			elseif ret == "com.game.sichuan" then 	--最新版本 1.0.7
				secret = "2d6ea71674fc61cba525c0bc0f5c339f"
				if gt.LastVersionNum() == 10 then
					secret = "3bc791b537f60a6ca8a8c54312562b4e"
				end
			elseif ret == "com.game.xiongmao" then
				secret = "3bc791b537f60a6ca8a8c54312562b4e"
			end
		else
			if appID == "wx01862222f922d138" then --老版APPstore版本
				secret = "a08740b80d37016355fdec8cd4cc089d"
			elseif appID == "wx848c15b329e26e8d" then 	--企业签名包
				secret = "284ee9ce1f70dc971241410cc75c9627"
			end
		end
	end

	local errorIP = nil
	for i,v in ipairs(self.wxLoginIP) do
		if self.errorIP then
			errorIP = self.errorIP
		else
	  		errorIP = v
		 end
		local accessTokenURL = string.format("https://"..errorIP.."/sns/oauth2/access_token?appid=%s&secret=%s&code=%s&grant_type=authorization_code", appID, secret, authCode)
		xhr:open("GET", accessTokenURL)
		local function onResp()
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
				local response = xhr.response
				require("json")
				local respJson = json.decode(response)
				if respJson.errcode then
					-- 申请失败
					require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0030"), nil, nil, true)
					gt.removeLoadingTips()
					self.autoLoginRet = false
					gt.log("xhr.readyState == 4 and errorCode")
				else
					self.errorIP = errorIP
					gt.log("xhr.readyState == 4 and not errorCode")
					local accessToken = respJson.access_token
					local refreshToken = respJson.refresh_token
					local openid = respJson.openid

					self:errLoginServerWeChat(accessToken, refreshToken, openid)--应该改为走error
				end
			elseif xhr.readyState == 1 and xhr.status == 0 then
				-- 本地网络连接断开
				gt.removeLoadingTips()
				self.autoLoginRet = false

				-- 切换微信授权的域名变为ip再次授权一次
				self:errPushWXAuthCode(authCode)
				gt.log("xhr.readyState == 1 and ...")

			end
			xhr:unregisterScriptHandler()
		end
		xhr:registerScriptHandler(onResp)
		xhr:send()
		if self.errorIP then
			break
		end
	end
end

function LoginScene:errRequestUserInfo(accessToken, refreshToken, openid)

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	if not self.errorIP then
		self.errorIP = "api.weixin.qq.com"
	end
	local userInfoURL = string.format("https://"..self.errorIP.."/sns/userinfo?access_token=%s&openid=%s", accessToken, openid)
	xhr:open("GET", userInfoURL)
	local function onResp()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local response = xhr.response
			require("json")
			response = string.gsub(response,"\\","")
			response = self:godNick(response)
			local respJson = json.decode(response)
			dump(respJson)
			if respJson.errcode then
				require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0030"))
				gt.removeLoadingTips()
				self.autoLoginRet = false
				
			else
				local sex 			= respJson.sex
				local nickname 		= respJson.nickname
				local headimgurl 	= respJson.headimgurl
				local unionid 		= respJson.unionid

				if buglyReportLuaException and not gt.debugMode then
					-- buglySetTag(1)
					buglyAddUserValue("sex",tostring(sex) or "")
					buglyAddUserValue("nickname",tostring(nickname) or "")
					buglyAddUserValue("headimgurl",tostring(headimgurl) or "")
					buglyAddUserValue("unionid",tostring(unionid) or "")
					buglyAddUserValue("accessToken",tostring(accessToken) or "")
					buglyAddUserValue("refreshToken",tostring(refreshToken) or "")
					buglyAddUserValue("openid",tostring(openid) or "")
					buglyAddUserValue("游戏本地版本",tostring(cc.exports.gt.resVersion) or "")
					buglyAddUserValue("是否第一次更新",tostring(cc.exports.gt.isUpdate) or "")
				else
					gt.log("buglyReportLuaException 为空")
				end

				-- 记录一下相关数据
				self.accessToken 	= accessToken
				self.refreshToken 	= refreshToken
				self.openid 		= openid
				self.sex 			= sex
				self.nickname 		= nickname
				self.headimgurl 	= headimgurl
				self.unionid 		= unionid
				gt.unionid = unionid

				gt.socketClient:setPlayerUUID(unionid)

				-- 测试模式走测试服务器
				if gt.debugIpGet then
					self:sendRealLogin(gt.TestLoginServer.ip,gt.TestLoginServer.port, accessToken, refreshToken, openid, sex, nickname, headimgurl, unionid)
				else
					self:getHttpServerIp(unionid)
					-- --读取上次成功的本地IP
					-- gt.LoginSuccessIp = cc.UserDefault:getInstance():getStringForKey("LoginSuccessIp")
					-- if string.len(gt.LoginSuccessIp) ==  0 then
					-- 	self:getHttpServerIp(unionid)--为空走ip策略
					-- else
					-- 	gt.log("读取gt.LoginSuccessIp = "..gt.LoginSuccessIp)
					-- 	local errorCode = gt.socketClient:connect(gt.LoginSuccessIp, gt.LoginServer.port, true)
					-- 	if errorCode == true then

					-- 		loginStrategy.ip = gt.LoginSuccessIp

					-- 		--保存本地
					-- 		cc.UserDefault:getInstance():setStringForKey("LoginSuccessIp", gt.LoginSuccessIp)

					-- 		gt.resume_time = 30

					-- 		local msgToSend = {}
					-- 		msgToSend.m_msgId = gt.CG_LOGIN
					-- 		msgToSend.m_plate = "wechat"
					-- 		msgToSend.m_accessToken = accessToken
					-- 		msgToSend.m_refreshToken = refreshToken
					-- 		msgToSend.m_openId = openid
					-- 		msgToSend.m_severID = 15001
					-- 		msgToSend.m_sex = tonumber(sex)
					-- 		msgToSend.m_nikename = nickname
					-- 		msgToSend.m_imageUrl = headimgurl
					-- 		msgToSend.m_uuid = unionid

					-- 		cc.UserDefault:getInstance():setStringForKey( "WX_Sex", tostring(sex) )
					-- 		cc.UserDefault:getInstance():setStringForKey( "WX_Uuid", unionid )
					-- 		gt.wxNickName = nickname
					-- 		cc.UserDefault:getInstance():setStringForKey( "WX_ImageUrl", self.headimgurl )


					-- 		local catStr = string.format("%s%s%s%s", openid, accessToken, refreshToken,unionid)
					-- 		msgToSend.m_md5 = cc.UtilityExtension:generateMD5(catStr, string.len(catStr))
					-- 		gt.socketClient:sendMessage(msgToSend)
					-- 	else
					-- 		self:getHttpServerIp(unionid)
					-- 		-- loginStrategy:getCdnIp()
					-- 	end
					-- end
				end

			end

		elseif xhr.readyState == 1 and xhr.status == 0 then
			-- 本地网络连接断开
			require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)
			gt.removeLoadingTips()
			self.autoLoginRet = false
				
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end


function LoginScene:errCheckAutoLogin()

	-- 获取记录中的token,freshtoken时间
	local accessTokenTime  = cc.UserDefault:getInstance():getStringForKey( "WX_Access_Token_Time" )
	local refreshTokenTime = cc.UserDefault:getInstance():getStringForKey( "WX_Refresh_Token_Time" )

	if string.len(accessTokenTime) == 0 or string.len(refreshTokenTime) == 0 then -- 未记录过微信token,freshtoken,说明是第一次登录
		gt.removeLoadingTips()
		return false
	end

	-- 检测是否超时
	local curTime = os.time()
	local accessTokenReconnectTime  = 5400    -- 3600*1.5   微信accesstoken默认有效时间未2小时,这里取1.5,1.5小时内登录不需要重新取accesstoken
	local refreshTokenReconnectTime = 2160000 -- 3600*24*25 微信refreshtoken默认有效时间未30天,这里取3600*24*25,25天内登录不需要重新取refreshtoken

	-- 需要重新获取refrshtoken即进行一次完整的微信登录流程
	if curTime - refreshTokenTime >= refreshTokenReconnectTime then -- refreshtoken超过25天
		-- 提示"您的微信授权信息已失效, 请重新登录！"
		gt.removeLoadingTips()
		require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0030"), nil, nil, true)
		return false
	end

	-- 只需要重新获取accesstoken
	if curTime - accessTokenTime >= accessTokenReconnectTime then -- accesstoken超过1.5小时
		local xhr = cc.XMLHttpRequest:new()
		xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
		local appID;
		if gt.isIOSPlatform() then
			local ok, ret = self.luaBridge.callStaticMethod("AppController", "getAppID")
			appID = ret
		elseif gt.isAndroidPlatform() then
			local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getAppID", nil, "()Ljava/lang/String;")
			appID = ret
		end
		local errorIP = nil
		for i,v in ipairs(self.wxLoginIP) do
			if self.errorIP then
				errorIP = self.errorIP
			else
		  		errorIP = v
			 end
			local refreshTokenURL = string.format("https://"..errorIP.."/sns/oauth2/refresh_token?appid=%s&grant_type=refresh_token&refresh_token=%s", appID, cc.UserDefault:getInstance():getStringForKey( "WX_Refresh_Token" ))
			xhr:open("GET", refreshTokenURL)
			local function onResp()
				gt.log("xhr.readyState is:" .. xhr.readyState .. " xhr.status is: " .. xhr.status)
				gt.removeLoadingTips()
				if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
					local response = xhr.response
					require("json")
					local respJson = json.decode(response)
					if respJson.errcode then
						-- 申请失败,清除accessToken,refreshToken等信息
						cc.UserDefault:getInstance():setStringForKey("WX_Access_Token", "")
						cc.UserDefault:getInstance():setStringForKey("WX_Refresh_Token", "")
						cc.UserDefault:getInstance():setStringForKey("WX_Access_Token_Time", "")
						cc.UserDefault:getInstance():setStringForKey("WX_Refresh_Token_Time", "")
						cc.UserDefault:getInstance():setStringForKey("WX_OpenId", "")

						-- 清理掉圈圈
						gt.removeLoadingTips()
						self.autoLoginRet = false

					else

						self.needLoginWXState = 2 -- 需要更新accesstoken以及其时间

						local accessToken = respJson.access_token
						local refreshToken = respJson.refresh_token
						local openid = respJson.openid
						self.errorIP = errorIP
						self:errLoginServerWeChat(accessToken, refreshToken, openid)

					end
				elseif xhr.readyState == 1 and xhr.status == 0 then
					-- 本地网络连接断开

					cc.UserDefault:getInstance():setStringForKey("WX_Access_Token", "")
					cc.UserDefault:getInstance():setStringForKey("WX_Refresh_Token", "")
					cc.UserDefault:getInstance():setStringForKey("WX_Access_Token_Time", "")
					cc.UserDefault:getInstance():setStringForKey("WX_Refresh_Token_Time", "")
					cc.UserDefault:getInstance():setStringForKey("WX_OpenId", "")

					gt.removeLoadingTips()
					self.autoLoginRet = false
					require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)

				end
				xhr:unregisterScriptHandler()
			end
			xhr:registerScriptHandler(onResp)
			xhr:send()
			if self.errorIP then
				break
			end
		end

		return true
	end

	-- accesstoken未过期,freshtoken未过期 则直接登录即可
	self.needLoginWXState = 1

	local accessToken 	= cc.UserDefault:getInstance():getStringForKey( "WX_Access_Token" )
	local refreshToken 	= cc.UserDefault:getInstance():getStringForKey( "WX_Refresh_Token" )
	local openid 		= cc.UserDefault:getInstance():getStringForKey( "WX_OpenId" )

	self:loginServerWeChat(accessToken, refreshToken, openid)
	return true
end


function LoginScene:errLoginServerWeChat(accessToken, refreshToken, openid)
	-- 保存下token相关信息,若验证通过,存储到本地
	self.m_accessToken 	= accessToken
	self.m_refreshToken = refreshToken
	self.m_openid 		= openid
	-- 请求昵称,头像等信息
	gt.showLoadingTips(gt.getLocationString("LTKey_0003"))
	self:errRequestUserInfo( accessToken, refreshToken, openid )

end



-----------------------------ip策略域名解析失败----------------------------

function LoginScene:getHttpServerIpError(uuid)	
	
	local servername = "sichuan"
	local srcSign = string.format("%s%s", uuid, servername)
	local sign = cc.UtilityExtension:generateMD5(srcSign, string.len(srcSign))
	local xhr = cc.XMLHttpRequest:new()
	xhr.timeout = 5
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local refreshTokenURL = string.format("http://218.11.1.112/security/server/getIPbyZoneUid")
	xhr:open("POST", refreshTokenURL)
	local function onResp()
		gt.log("xhr.readyState = " .. xhr.readyState .. ", xhr.status = " .. xhr.status)
		gt.log("xhr.statusText = " .. xhr.statusText)
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local response = xhr.response
			dump(response)
			require("json")
			local respJson = json.decode(response)
			
			if respJson.errorCode == 0 then 

				self:sendRealLogin(respJson.ip,gt.LoginServer.port,self.accessToken, self.refreshToken, self.openid, self.sex, self.nickname, self.headimgurl, self.unionid)
			else
				-- 第一次登录重连
				gt.socketClient:reloginServer()
			end
		elseif xhr.readyState == 1 and xhr.status == 0 then
			
			gt.socketClient:reloginServer()

		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send(string.format("uuid=%s&servername=%s&sign=%s", uuid, servername, sign))
end

return LoginScene

