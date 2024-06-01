# SCHALE.GameServer_USE
**本文基于[https://github.com/rafi1212122/SCHALE.GameServer](https://github.com/rafi1212122/SCHALE.GameServer)及个人操作经验编写，资源配置文件请到以上链接获取，若有任何疑问请到Discord社群询问**
## 安装准备阶段
### 1.安装[SQL Server Express 2022](https://go.microsoft.com/fwlink/p/?linkid=2216019&clcid=0x804&culture=zh-cn&country=cn)
  * 打开你下载的安装程序
  * 选择“基础”
  * 选择你习惯的安装路径
  * 开始安装
### 2.安装[SSMS(SQL Server Management Studio 20)](https://aka.ms/ssmsfullsetup)
  * 路径默认即可
  * 安装
### 3.安装[Microsoft Visual Studio 2022](https://visualstudio.microsoft.com/zh-hans/thank-you-downloading-visual-studio/?sku=Community&channel=Release&version=VS2022&source=VSLandingPage&cid=2030&passive=false)
  * 安装Community版
  * 工作负荷选择所有带有C#的组件以及“Visual Studio扩展开发”
  * 直接默认路径安装
### 4.安装[雷电模拟器9](https://lddl01.ldmnq.com/downloader/ldplayerinst9.exe?n=ldplayer9_ld_999_ld.exe)
### 5.安装[Python](https://www.python.org/ftp/python/3.12.3/python-3.12.3-amd64.exe)
  * 选择自定义安装，其余默认
  * 选择安装路径
  * 安装，等待完成
### 6.安装Frida
  * win+R打开运行，键入cmd
  * 在cmd中输入`pip install frida`回车
  * 等待下载安装完成
  * 再输入`pip install frida-tools`回车
  * 等待下载安装完成（时间可能较长）
### 7.推送Frida-server至模拟器
  * 下载[frida-server-16.x.x-android-x86_64.xz](https://github.com/frida/frida/releases/download/16.3.1/frida-server-16.3.1-android-x86_64.xz)并解压
  * 把frida-server-16.x.x-android-x86_64放入`\leidian\LDPlayer9`路径下
  * 打开模拟器并在设置中打开ADB调试和ROOT权限
  * 在（你安装时的盘）:\leidian\LDPlayer9路径下的导航栏中输入cmd并回车
  * 输入`adb push frida-server-16.x.x-android-x86_64 /data/local/tmp`
  * 等待传输完成
## 资源配置阶段
  * 打开并解压所下载的SCHALE.GameServer-master.zip  
  * 使用Microsoft Visual Studio 2022打开包中的SCHALE.GameServer.sln  
  * 选择顶部菜单栏“视图”下拉“终端”  
  * 若在`...\SCHALE.GameServer-master>`下，请输入`cd SCHALE.GameServer`转到以下路径  
  * 在`\SCHALE.GameServer-master\SCHALE.GameServer`路径下输入：  
    `dotnet publish -a x64 --use-current-runtime --self-contained false -p:InvariantGlobalization=false`  
  * ~~找到并在`\SCHALE.GameServer-master\SCHALE.GameServer\bin\Release\net8.0\win-x64`路径下创建Resources文件夹，再在其下创建excel文件夹，将Excel.zip解压至此文件夹~~（最新版该步骤已集成于`SCHALE.GameServer.exe`）
  * 打开SSMS，默认连接（注意勾选信任服务器证书）  
  * 运行`\SCHALE.GameServer-master\SCHALE.GameServer\bin\Release\net8.0\win-x64\SCHALE.GameServer.exe` （后台挂起）（首次运行请允许通过防火墙） 
  * 找到ba.js文件使用记事本打开，修改第5行`REPLACE THIS WITH YOUR LOCAL IP`为你此时的IPV4地址（网络和Internet设置中可查看）  
## 启动游戏阶段
  *建议把ba.js放入\leidian\LDPlayer9路径下*
    
  **以下操作每次启动都要执行！**
  * 打开雷电模拟器
  * 启动frida
      * 在（你安装时的盘）:\leidian\LDPlayer9路径下的导航栏中输入cmd并回车
      * 在所打开的cmd中键入:
        ```
        adb shell
        su    //超级管理员
        cd /data/local/tmp    //转到此路径下
        chmod 755 frida-server-16.x.x-android-x86_64
        ./frida-server-16.x.x-android-x86_64    //启动frida
        ```
    **！！！注意此步骤完成后不要关闭该cmd！！！**  
  
  * （PC）重新打开一个路径相同的cmd
  * （模拟器）启动游戏 ブルアカ
  * 在出现Yostar徽标时键入并回车：  
    `frida -U "ブルアカ" -l ba.js --realm=emulated`（后台挂起）
  * 出现`Attatching...`并且SCHALE.GameServer.exe出现Ping时基本成功
   
  **###进入私服前需要先连接官服下载资源并通过新手教程###**  
  
  **###首次登录设置完名称和发音档时会抛出错误，此时重启`SCHALE.GameServer.exe`、关闭游戏，从“启动游戏ブルアカ”步骤再次开始即可正常进入###**
  
## 注意事项
  * 此项目还处于初期阶段，存在大量不可使用选项，出现问题请尝试重新登录或重启
  * 若出现`SCHALE.GameServer.exe`没有Ping的情况，请检查ba.js中的IPV4地址与你当前地址是否一致
  * 若已成功安装SQL Server Express，请不要轻易自行尝试卸载或删除它，否则可能无法再次成功安装
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
