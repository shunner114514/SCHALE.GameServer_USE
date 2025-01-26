# SCHALE.GameServer_USE
**本文基于**~~[https://git.lewd.wtf/Raphael/SCHALE.GameServer](https://git.lewd.wtf/Raphael/SCHALE.GameServer)~~**及个人操作经验编写，资源配置文件请到以上链接获取，若有任何疑问请到Discord社群询问（以上项目现已停止维护，现请转到[https://git.fufufu.moe/KaniPS/Phrenapates](https://git.fufufu.moe/KaniPS/Phrenapates)）**
## 安装准备（若有问题，请参看注意事项）
### 1.安装[SQL Server Express 2022](https://www.microsoft.com/zh-cn/download/details.aspx?id=104781)
  * 打开下载的安装程序
  * 选择“基础”
  * 选择习惯的安装路径
  * 开始安装
### 2.安装[SSMS(SQL Server Management Studio 20)](https://aka.ms/ssmsfullsetup)
  * 路径默认安装
### 3.安装[Microsoft Visual Studio 2022](https://visualstudio.microsoft.com/zh-hans/thank-you-downloading-visual-studio/?sku=Community&channel=Release&version=VS2022&source=VSLandingPage&cid=2030&passive=false)
  * 安装Community版
  * 工作负荷选择所有带有C#的组件以及“Visual Studio扩展开发”
  * 默认路径安装
### 4.安装[雷电模拟器9](https://www.ldmnq.com/?n=401674)或[MuMu模拟器12](https://mumu.163.com/)
### 5.安装[Python](https://www.python.org/downloads/)
  * Downlaod Python 最新版本
  * 打开安装程序选择自定义(Customize)安装，其余默认
  * 选择安装路径
  * 安装，等待完成
### 6.（Frida方案）安装Frida
  * win+R打开运行，键入cmd
  * 在cmd中输入`pip install frida`回车
  * 等待下载安装完成
  * 再输入`pip install frida-tools`回车
  * 等待下载安装完成（时间可能较长）
### 7.[推荐]（mtimproxy方案）[模拟器]安装[WireGuard](https://www.wireguard.com/install/)
  * 点击`Download APK File`下载安装包
  * 在模拟器中安装

## 配置资源
  * 打开并解压所下载的SCHALE.GameServer-master.zip  
  * 使用Microsoft Visual Studio 2022打开包中的SCHALE.GameServer.sln
     * 检查`appsettings.json`中`data source=主机名\\实例名`是否与SSMS中的一致
      * 选择顶部菜单栏“视图”下拉“终端”  
      * 若在`...\schale.gameserver>`下，请输入`cd SCHALE.GameServer`转到以下路径
      * 在`\schale.gameserver\SCHALE.GameServer`路径下输入：  
        `dotnet publish -a x64 --use-current-runtime --self-contained false -p:InvariantGlobalization=false`  
      * ~~找到并在`\SCHALE.GameServer\SCHALE.GameServer\bin\Release\net8.0\win-x64`路径下创建Resources文件夹，再在其下创建excel文件夹，将Excel.zip解压至此文件夹~~（最新版该步骤已集成于`SCHALE.GameServer.exe`（下载缓慢请挂代理））
  * 打开SSMS，Windows身份验证，默认连接（注意勾选信任服务器证书）   
## 配置重定向
*需在模拟器设置中打开ADB调试和ROOT权限*
### Frida方案

**推送Frida-server至模拟器**
  * 下载[frida-server-16.x.x-android-x86_64.xz](https://github.com/frida/frida/releases)最新版并解压
  * 把`frida-server-16.x.x-android-x86_64`放入`(安装盘):\leidian\LDPlayer9`或`(安装盘):\MuMuPlayer-12.0\shell`路径下
  * 在模拟器路径下的导航栏中输入cmd并回车
  * 输入`adb push frida-server-16.x.x-android-x86_64 /data/local/tmp`
  * 等待推送完成

**修改ba.js文件**
  * 找到`...\Scripts\redirect_server_frida\ba.js`文件并使用记事本打开，修改第5行`REPLACE THIS WITH YOUR LOCAL IP`为你此时的IPV4地址（网络和Internet设置中可查看）  
  * 保存后将其放至`\leidian\LDPlayer9`或`\MuMuPlayer-12.0\shell`

### mtimproxy方案
*模拟器需打开"可写系统盘"*

**修改redirect_server.py文件**  
  * 找到`...\Scripts\redirect_server_mitmproxy\redirect_server.py`文件并使用记事本打开，修改`YOUR_SERVER_HERE`为本地服务器host（如：`127.0.0.1`）

**PC端**  
  * 下载[mtimproxy](https://mitmproxy.org/)安装器，并选择路径安装
  * 在`...\Scripts\redirect_server_mitmproxy`文件夹下点击导航栏，输入`cmd`并回车
  * 在打开的cmd中输入`mitmweb -m wireguard --no-http2 -s redirect_server.py --set termlog_verbosity=warn --ignore-hosts 你的IPv4地址`来启动mtimproxy
    * 点击`Capture`，记录“WireGuard Server”下`[Interface]`和`[Peer]`中的共六个数据以备用
  * 在`C:\Users(用户)\当前登录的用户\.mitmproxy`下找到`mitmproxy-ca-cert.cer`，复制一份并将其重命名为`c8750f0d.0`
  * 将`c8750f0d.0`放在`\leidian\LDPlayer9`或`\MuMuPlayer-12.0\shell`路径下
  * 打开模拟器并在模拟器路径下的导航栏中输入cmd并回车
  * 依次输入  
    `adb push c8750f0d.0 /system/etc/security/cacerts`  
    `adb shell chmod 664 /system/etc/security/cacerts/c8750f0d.0  //MuMu模拟器删去 "/system"` 
  * 证书传入完毕 

**模拟器**  
  * 打开WireGuard
  * 点击加号，选择"手动创建"
  * 本地(interface)  
    * 名称：任意命名
    * 私钥：填入记下的`PrivateKey`
    * 局域网IP地址：填入记下的`Address`
    * DNS服务器：填入记下的`DNS`
  * 点击"添加节点"
  * 远程(Peer)
    * 公钥：填入记下的`PublicKey`
    * 对端：填入记下的`Endpoint`
    * 路由的IP地址：填入记下的`AllowedIPs`
  * 保存并开启

## 启动游戏
运行`\schale.gameserver\SCHALE.GameServer\bin\Release\net8.0\win-x64\SCHALE.GameServer.exe` （后台挂起）（首次运行请允许通过防火墙）
### Frida方案
*以下操作每次启动都要执行！*
  * 打开模拟器
  * 启动frida
      * 在模拟器路径下的导航栏中输入cmd并回车
      * 在所打开的cmd中依次输入:  
        ```adb shell```  
        ```su    //超级管理员```  
        ```cd /data/local/tmp    //转到此路径下```  
        ```chmod 755 frida-server-16.x.x-android-x86_64```  
        ```./frida-server-16.x.x-android-x86_64    //启动frida```  
    **！！！注意此步骤完成后不要关闭该cmd！！！**  
  
  * （PC）重新打开一个路径相同的cmd
  * （模拟器）启动游戏 `ブルアカ`
  * 在出现Yostar徽标时键入并回车：  
    `frida -U "ブルアカ" -l ba.js --realm=emulated`（后台挂起）
  * 出现`Attatching...`并且`SCHALE.GameServer.exe`出现Ping响应时基本成功

### mtimproxy方案
  * 打开模拟器中WireGuard
  * 在`...\Scripts\redirect_server_mitmproxy`文件夹下点击导航栏，输入`cmd`并回车
  * 在打开的cmd中输入`mitmweb -m wireguard --no-http2 -s redirect_server.py --set termlog_verbosity=warn --ignore-hosts 你的IPv4地址`来启动mtimproxy  
  **# 请勿关闭该cmd #** 
  * 握手成功后，启动游戏`ブルアカ`
  * `SCHALE.GameServer.exe`出现Ping响应时基本成功

  **###进入私服前需要先连接官服下载资源并通过新手教程###**  
  
  ~~**###首次登录设置完名称和发音档时会抛出错误，此时重启`SCHALE.GameServer.exe`、关闭游戏，从“启动游戏ブルアカ”步骤再次开始即可正常进入###**~~
  
## 注意事项
  * 此项目仍处于开发阶段，出现问题请尝试重新登录或重启服务器
  * 若`SCHALE.GameServer.exe`没有出现Ping，请检查`ba.js`中的IPV4地址与你当前地址或检查`appsettings.json`中主机名和实例名是否与你电脑上的一致
  * 若已成功安装SQL Server Express，请不要轻易自行尝试卸载或删除它，否则可能无法再次成功安装
  * **[解决方案]** 若尝试重新安装SQL失败，请安装[Total Uninstall](https://www.martau.com/zh-CN/uninstaller-download.php)删除全部关于SQL Server的文件（注意有关文件的时间一般是一样的）  
    具体请参照[SQL Server 2019重新安装失败的处理方法](https://blog.csdn.net/dian_dian_tou/article/details/106116481)
  * 如果很不幸，你的电脑上已经多次无法成功安装SQL Server Express且不愿意重装系统，以下提供一个平替方案：  
    *需要较高性能的电脑和足够的硬盘存储*
    * 安装[VMware Workstation Pro](https://blog.csdn.net/weixin_74195551/article/details/127288338)
    * 网络搜索许可证密钥填入
    * 前往Windows官网或其他正规渠道获取Windows 10/11镜像
    * 创建并安装Windows虚拟机  
      参阅[VMware中安装win10教程_vmware安装win10-CSDN博客](https://blog.csdn.net/lvlheike/article/details/120398259)
    * 创建完虚拟机需设置：
      * 你的电脑：设置-系统-屏幕-显示卡-默认图形设置，启用“硬件加速GPU计划”
      * （虚拟机设置）处理器：勾选虚拟化Intel VT-x/EPT或AMD-V/RVI(V)
      * （虚拟机设置）显示器：勾选“加速3D图形”，选择“指定监视器设置”，监视器数量为1个，图形内存改为所给**内存**的一半
    * 启动虚拟机
    * 使用[KMS](https://github.com/zbezj/HEU_KMS_Activator/releases/tag/42.0.4)激活Windows
    * 完成后即可开始安装
