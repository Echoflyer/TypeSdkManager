<h2 style="margin-top:5px;margin-right:0;margin-bottom:16px;margin-left: 0">
    <a></a><span style="color: rgb(0, 0, 0);"><strong><span style="text-decoration: none; font-size: 19px; line-height: 173%; font-family: 微软雅黑, sans-serif; background: white;">TypeSdk是一个手机游戏渠道SDK开源接入框架，解决手机游戏发布需要耗费大量人力和时间接入不同渠道SDK的问题， 并解决发行过程中大量隐藏的问题，实现一次接入多渠道上线。 TypeSDK支持Unity3D、cocos2项目开发的手机游戏，支持发布Android和IOS游戏渠道包。 游戏开发者可安上线需求自行部署和管理线上环境和编译环境， 运营数据不通过第三方转发，直接与渠道签约和收款，无需担心游戏代码外泄、运营数据外流、</span></strong><strong style="color: rgb(0, 0, 0);"><span style="text-decoration: none; font-size: 19px; line-height: 173%; font-family: 微软雅黑, sans-serif; background: white;">被第三</span></strong><strong style="text-decoration: none;"><span style="text-decoration: none; font-size: 19px; line-height: 173%; font-family: 微软雅黑, sans-serif; background: white;">方扣量扣款等风<span style="text-decoration: none; font-size: 19px; line-height: 173%; font-family: 微软雅黑, sans-serif; background: white; color: rgb(0, 0, 0);">险</span><span style="color:#548dd4"><span style="text-decoration: none; font-size: 19px; line-height: 173%; font-family: 微软雅黑, sans-serif; background: white; color: rgb(0, 0, 0);">。</span></span></span></strong></span>
</h2>
<hr/>
<h2 style="margin-top:5px;margin-right:0;margin-bottom:16px;margin-left: 0">
    <span style="color: rgb(84, 141, 212);"><strong><span style="font-size: 19px; line-height: 173%; font-family: 黑体;">TypeSdkManager</span></strong><strong><span style="font-size: 19px; line-height: 173%; font-family: 黑体;">是TypeSdk统一渠道接入框架的集中管理平台，主要包含：</span></strong></span>
</h2>
<h2 style="margin-top:5px;margin-right:0;margin-bottom:16px;margin-left: 0">
    <strong style="color: rgb(84, 141, 212); text-indent: 40px; font-size: 16px;"><span style="font-size: 19px; line-height: 173%; font-family: 黑体;">1</span></strong><strong style="color: rgb(84, 141, 212); text-indent: 40px; font-size: 16px;"><span style="font-size: 19px; line-height: 173%; font-family: 黑体;">、游戏渠道打包</span></strong>
</h2>
<h2 style="margin-top:5px;margin-right:0;margin-bottom:16px;margin-left: 0">
    <strong style="color: rgb(84, 141, 212); text-indent: 40px; font-size: 16px;"><span style="font-size: 19px; line-height: 173%; font-family: 黑体;">2</span></strong><strong style="color: rgb(84, 141, 212); text-indent: 40px; font-size: 16px;"><span style="font-size: 19px; line-height: 173%; font-family: 黑体;">、渠道SDK管理</span></strong>
</h2>
<h2 style="margin-top:5px;margin-right:0;margin-bottom:16px;margin-left: 0">
    <strong style="color: rgb(84, 141, 212); text-indent: 40px; font-size: 16px;"><span style="font-size: 19px; line-height: 173%; font-family: 黑体;">3</span></strong><strong style="color: rgb(84, 141, 212); text-indent: 40px; font-size: 16px;"><span style="font-size: 19px; line-height: 173%; font-family: 黑体;">、渠道参数管理</span></strong>
</h2>
<h2 style="margin-top:5px;margin-right:0;margin-bottom:16px;margin-left: 0">
    <strong style="color: rgb(84, 141, 212); text-indent: 40px; font-size: 16px;"><span style="font-size: 19px; line-height: 173%; font-family: 黑体;">4</span></strong><strong style="color: rgb(84, 141, 212); text-indent: 40px; font-size: 16px;"><span style="font-size: 19px; line-height: 173%; font-family: 黑体;">、游戏版本管理</span></strong>
</h2>
<h2 style="margin-top:5px;margin-right:0;margin-bottom:16px;margin-left: 0">
    <strong style="color: rgb(84, 141, 212); text-indent: 40px; font-size: 16px;"><span style="font-size: 19px; line-height: 173%; font-family: 黑体;">5、游戏渠道包管理</span></strong>
</h2>
<p>
    <a></a><a></a>
</p>
<hr/>
<h3 style="margin: 16px 0;background: white">
    <span style="font-size: 19px; font-family: 黑体; color: rgb(255, 0, 0);">特别注意：</span>
</h3>
<h3 style="margin: 16px 0;background: white">
    <span style="color: rgb(255, 0, 0);"><span style="font-size: 19px; font-family: Arial, sans-serif;">1</span><span style="font-size: 19px;">、</span></span><span style="color: rgb(255, 0, 0);">Manager和Packge两个模块统称为打包工具（一个管理一个调度）</span>
</h3>
<h3 style="margin: 16px 0;background: white">
    <span style="color: rgb(255, 0, 0);"><span style="color: rgb(255, 0, 0); font-size: 19px; font-family: Arial, sans-serif;">2</span><span style="color: rgb(255, 0, 0); font-size: 19px;">、</span><span style="color: rgb(255, 0, 0); font-size: 19px; font-family: 黑体;">简单理解为Manager就是整个统一接入框架的用户操作和管理模块，</span>该项目使用.NET4.5编写。</span>
</h3>
<h3 style="margin: 16px 0;background: white">
    <span style="color: rgb(255, 0, 0);"><span style="font-size: 19px; font-family: Arial, sans-serif;">3</span><span style="font-size: 19px;">、一键安装包请到官网下载，GIT上仅放源码</span></span>
</h3>
<p>
    <span style="color: rgb(255, 0, 0);"><span style="font-size: 19px; font-family: 黑体;"></span></span>
</p>
<hr/>
<p style="margin: 5px 0 16px">
    <span style="font-family: 黑体"></span>
</p>
<p style="white-space: normal;">
    <span style="font-family: 黑体;">联系QQ：1771930259</span><br/>
</p>
<p style="margin-top: 0px; margin-bottom: 16px; white-space: normal;">
    <span style="font-family: 黑体;">官方网站：</span><a href="http://www.typesdk.com/"><span style="font-family: 黑体; color: black;">http://www.typesdk.com</span></a>
</p>
<p style="margin-top: 0px; margin-bottom: 16px; white-space: normal;">
    <span style="font-family: 黑体;">支持渠道：自建渠道；国内渠道；海外渠道；第三方支付；海外广告分析；海外广告检测，游戏好友分享</span>
</p>
<p style="margin-top: 0px; margin-bottom: 16px; white-space: normal;">
    <span style="font-family: 黑体;">TypeSdk文档：</span><a href="http://www.typesdk.com/documents" target="_blank">文档中心</a>
</p>
<p style="margin-top: 0px; margin-bottom: 16px; white-space: normal;">
    <span style="font-family: 黑体;">打包工具DEMO演示地址：</span><a href="http://demo.typesdk.com:56789/"><span style="font-family: 黑体; color: black;">演示地址</span></a><span style="font-family: Calibri, sans-serif;">&nbsp;</span><span style="font-family: 黑体;">（用户名和密码：demo@typesdk.com/123.com）</span>
</p>