// ------------------------------------------------------------
// A 16-gauge pump for hunting
// ------------------------------------------------------------
class Hunter16:HD16GaugeShotgun{
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "Hunter 16g"
		//$Sprite "HU16A0"

		weapon.selectionorder 31;
		weapon.slotnumber 3;
		weapon.slotpriority 1;
		weapon.bobrangex 0.21;
		weapon.bobrangey 0.9;
		scale 0.57;
		inventory.pickupmessage "Market demands engaugement";
		hdweapon.barrelsize 40,0.5,2;
		hdweapon.refid "h16";
		tag "sporting shotgun";
		obituary "Hunted";

		hdweapon.loadoutcodes "
			\cutype - 0-2, export/regular/hacked
			\cufiremode - 0-2, pump/semi/auto, subject to the above
			\cuchoke - 0-7, 0 skeet, 7 full";
	}
	//returns the power of the load just fired
	static double Fire(actor caller,int choke=1){
		double spread=6.;
		double speedfactor=1.;
		let hhh=Hunter16(caller.findinventory("Hunter16"));
		if(hhh)choke=hhh.weaponstatus[HU16S_CHOKE];

		choke=clamp(choke,0,7);
		spread=6.5-0.5*choke;
		speedfactor=1.+0.02857*choke;

		double shotpower=getshotpower();
		spread*=shotpower;
		speedfactor*=shotpower;
		HDBulletActor.FireBullet(caller,"HDB_wad");
		let p=HDBulletActor.FireBullet(caller,"HDB_SingleOught",
			spread:spread,speedfactor:speedfactor,amount:9
		);
		distantnoise.make(caller,"world/shotgunfar");
		caller.A_StartSound("weapons/hunter",CHAN_WEAPON,CHANF_OVERLAP);
		return shotpower;
	}
	const HUNTER_MINSHOTPOWER=0.901;
	action void A_FireHunter16(){
		double shotpower=invoker.Fire(self);
		A_GunFlash();
		vector2 shotrecoil=(randompick(-1,1),-2.6);
		if(invoker.weaponstatus[HU16S_FIREMODE]>0)shotrecoil=(randompick(-1,1)*1.4,-3.4);
		shotrecoil*=shotpower;
		A_MuzzleClimb(0,0,shotrecoil.x,shotrecoil.y,randompick(-1,1)*shotpower,-0.3*shotpower);
		invoker.weaponstatus[HU16S_CHAMBER]=1;
		invoker.shotpower=shotpower;
	}
	override string pickupmessage(){
		String msg=super.pickupmessage();
		if(weaponstatus[0]&HU16F_CANFULLAUTO)return msg..Stringtable.Localize("$PICKUP_HUNTER_AUTO16");
		if(weaponstatus[0]&HU16F_EXPORT)return msg..Stringtable.Localize("$PICKUP_HUNTER_EXPORT16");
		return msg;
	}
	override string,double getpickupsprite(bool usespare){return "HUNT"..getpickupframe(usespare).."0",1.;}
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			sb.drawimage("2341A0",(-47,-10),basestatusbar.DI_SCREEN_CENTER_BOTTOM);
			sb.drawnum(hpl.countinv("HD16Gauge275InchShellAmmo"),-46,-8,
				basestatusbar.DI_SCREEN_CENTER_BOTTOM
			);
		}
		if(hdw.weaponstatus[HU16S_CHAMBER]>1){
			sb.drawrect(-24,-14,5,3);
			sb.drawrect(-18,-14,2,3);
		}
		else if(hdw.weaponstatus[HU16S_CHAMBER]>0){
			sb.drawrect(-18,-14,2,3);
		}
		if(!(hdw.weaponstatus[0]&HU16F_EXPORT))sb.drawwepcounter(hdw.weaponstatus[HU16S_FIREMODE],
			-26,-12,"blank","RBRSA3A7","STFULAUT"
		);
		sb.drawwepnum(hdw.weaponstatus[HU16S_TUBE],hdw.weaponstatus[HU16S_TUBESIZE],posy:-7);
		for(int i=hdw.weaponstatus[SH16S_SIDESADDLE];i>0;i--){
			sb.drawrect(-16-i*2,-5,1,3);
		}
	}
	override string gethelptext(){
		LocalizeHelp();
		return
		LWPHELP_FIRE..StringTable.Localize("$SHOOT_CH")..weaponstatus[HU16S_CHOKE]..")\n"
		..LWPHELP_ALTFIRE..StringTable.Localize("$PUMP")
		..LWPHELP_RELOAD..StringTable.Localize("$SHTG_REL1")
		..LWPHELP_ALTRELOAD..StringTable.Localize("$SHTG_REL2")
		..(weaponstatus[0]&HU16F_EXPORT?"":(LWPHELP_FIREMODE..StringTable.Localize("$SHTG_FMODE")..(weaponstatus[0]&HU16F_CANFULLAUTO?"/Auto":"").."\n"))
		..LWPHELP_FIREMODE.."+"..LWPHELP_RELOAD..StringTable.Localize("$SHTG_SIDE")
		..LWPHELP_USE.."+"..LWPHELP_UNLOAD..StringTable.Localize("$SHTG_STEAL")
		..LWPHELP_UNLOADUNLOAD
		;
	}
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc
	){
		int cx,cy,cw,ch;
		[cx,cy,cw,ch]=screen.GetClipRect();
		sb.SetClipRect(
			-16+bob.x,-32+bob.y,32,40,
			sb.DI_SCREEN_CENTER
		);
		vector2 bobb=bob*1.1;
		sb.drawimage(
			"frntsite",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
		);
		sb.SetClipRect(cx,cy,cw,ch);

		sb.drawimage(
			"sgbaksit",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9
		);
	}
	override double gunmass(){
		int tube=weaponstatus[HU16S_TUBE];
		if(tube>4)tube+=(tube-4)*2;
		return 8+tube*0.3+weaponstatus[SH16S_SIDESADDLE]*0.08;
	}
	override double weaponbulk(){
		return 130+(weaponstatus[SH16S_SIDESADDLE]+weaponstatus[HU16S_TUBE])*ENC_16SHELLLOADED234;
	}
	action void A_SwitchFireMode(bool forwards=true){
		if(invoker.weaponstatus[0]&HU16F_EXPORT){
			invoker.weaponstatus[HU16S_FIREMODE]=0;
			return;
		}
		int newfm=invoker.weaponstatus[HU16S_FIREMODE]+(forwards?1:-1);
		int newmax=(invoker.weaponstatus[0]&HU16F_CANFULLAUTO)?2:1;
		if(newfm>newmax)newfm=0;
		else if(newfm<0)newfm=newmax;
		invoker.weaponstatus[HU16S_FIREMODE]=newfm;
	}
	action void A_SetAltHold(bool which){
		if(which)invoker.weaponstatus[0]|=HU16F_ALTHOLDING;
		else invoker.weaponstatus[0]&=~HU16F_ALTHOLDING;
	}
	action void A_Chamber(bool careful=false){
		int chm=invoker.weaponstatus[HU16S_CHAMBER];
		invoker.weaponstatus[HU16S_CHAMBER]=0;
		if(invoker.weaponstatus[HU16S_TUBE]>0){
			invoker.weaponstatus[HU16S_CHAMBER]=2;
			invoker.weaponstatus[HU16S_TUBE]--;
		}
		vector3 cockdir;double cp=cos(pitch);
		if(careful)cockdir=(-cp,cp,-5);
		else cockdir=(0,-cp*5,sin(pitch)*frandom(4,6));
		cockdir.xy=rotatevector(cockdir.xy,angle);
		bool pocketed=false;
		if(chm>1){
			if(careful&&!A_JumpIfInventory("HD16Gauge275InchShellAmmo",0,"null")){
				HDF.Give(self,"HD16Gauge275InchShellAmmo",1);
				pocketed=true;
			}
		}else if(chm>0){	
			cockdir*=frandom(1.,1.3);
		}

		if(
			!pocketed
			&&chm>=1
		){
			if(chm>1)A_EjectCasing("HD16GaugeFumblingShell",
				frandom(-1,2),
				(frandom(0.2,0.25),-frandom(5,5.2),frandom(0,0.15)),
				(0,0,-2)
			);
			else A_EjectCasing("HD16GaugeSpentShell",
				frandom(-1,2),
				(frandom(0.25,0.3),-frandom(6,6.5),frandom(0,0.2)),
				(0,0,-2)
			);
		}
	}
	action void A_CheckPocketSaddles(){
		if(invoker.weaponstatus[SH16S_SIDESADDLE]<1)invoker.weaponstatus[0]|=HU16F_FROMPOCKETS;
		if(!countinv("HD16Gauge275InchShellAmmo"))invoker.weaponstatus[0]&=~HU16F_FROMPOCKETS;
	}
	action bool A_LoadTubeFromHand(){
		int hand=invoker.handshells16;
		if(
			!hand
			||(
				invoker.weaponstatus[HU16S_CHAMBER]>0
				&&invoker.weaponstatus[HU16S_TUBE]>=invoker.weaponstatus[HU16S_TUBESIZE]
			)
		){
			EmptyHand16();
			return false;
		}
		invoker.weaponstatus[HU16S_TUBE]++;
		invoker.handshells16--;
		A_StartSound("weapons/huntreload",8,CHANF_OVERLAP);
		return true;
	}
	action bool A_GrabShells(int maxhand=3,bool settics=false,bool alwaysone=false){
		if(maxhand>0)EmptyHand16();else maxhand=abs(maxhand);
		bool fromsidesaddles=!(invoker.weaponstatus[0]&HU16F_FROMPOCKETS);
		int toload=min(
			fromsidesaddles?invoker.weaponstatus[SH16S_SIDESADDLE]:countinv("HD16Gauge275InchShellAmmo"),
			alwaysone?1:(invoker.weaponstatus[HU16S_TUBESIZE]-invoker.weaponstatus[HU16S_TUBE]),
			maxhand
		);
		if(toload<1)return false;
		invoker.handshells16=toload;
		if(fromsidesaddles){
			invoker.weaponstatus[SH16S_SIDESADDLE]-=toload;
			if(settics)A_SetTics(2);
			A_StartSound("weapons/pocket",8,CHANF_OVERLAP,0.4);
			A_MuzzleClimb(
				frandom(0.1,0.15),frandom(0.05,0.08),
				frandom(0.1,0.15),frandom(0.05,0.08),
				wepdot:false
			);
		}else{
			A_TakeInventory("HD16Gauge275InchShellAmmo",toload,TIF_NOTAKEINFINITE);
			if(settics)A_SetTics(7);
			A_StartSound("weapons/pocket",9);
			A_MuzzleClimb(
				frandom(0.1,0.15),frandom(0.2,0.4),
				frandom(0.2,0.25),frandom(0.3,0.4),
				frandom(0.1,0.35),frandom(0.3,0.4),
				frandom(0.1,0.15),frandom(0.2,0.4),
				wepdot:false
			);
		}
		return true;
	}
	states{
	select0:
		SHTG A 0;
		goto select0big;
	deselect0:
		SHTG A 0;
		goto deselect0big;
	firemode:
		SHTG A 0 a_switchfiremode();
	firemodehold:
		---- A 1{
			if(pressingreload()){
				a_switchfiremode(false); //untoggle
				setweaponstate("reloadss");
			}else A_WeaponReady(WRF_NOFIRE);
		}
		---- A 0 A_JumpIf(pressingfiremode()&&invoker.weaponstatus[SH16S_SIDESADDLE]<12,"firemodehold");
		goto nope;
	ready:
		SHTG A 0 A_JumpIf(pressingunload()&&(pressinguse()||pressingzoom()),"cannibalize");
		SHTG A 0 A_JumpIf(pressingaltfire(),2);
		SHTG A 0{
			if(!pressingaltfire()){
				if(!pressingfire())A_ClearRefire();
				A_SetAltHold(false);
			}
		}
		SHTG A 1 A_WeaponReady(WRF_ALL);
		goto readyend;
	reloadSS:
		SHTG A 1 offset(1,34);
		SHTG A 2 offset(2,34);
		SHTG A 3 offset(3,36);
	reloadSSrestart:
		SHTG A 6 offset(3,35);
		SHTG A 9 offset(4,34);
		SHTG A 4 offset(3,34){
			int hnd=min(
				countinv("HD16Gauge275InchShellAmmo"),
				12-invoker.weaponstatus[SH16S_SIDESADDLE],
				3
			);
			if(hnd<1)setweaponstate("reloadSSend");
			else{
				A_TakeInventory("HD16Gauge275InchShellAmmo",hnd);
				invoker.weaponstatus[SH16S_SIDESADDLE]+=hnd;
				A_StartSound("weapons/pocket",8);
			}
		}
		SHTG A 0 {
			if(
				!PressingReload()
				&&!PressingAltReload()
			)setweaponstate("reloadSSend");
			else if(
				invoker.weaponstatus[SH16S_SIDESADDLE]<12
				&&countinv("HD16Gauge275InchShellAmmo")
			)setweaponstate("ReloadSSrestart");
		}
	reloadSSend:
		SHTG A 3 offset(2,34);
		SHTG A 1 offset(1,34) EmptyHand16(careful:true);
		goto nope;
	hold:
		SHTG A 0{
			bool paf=pressingaltfire();
			if(
				paf&&!(invoker.weaponstatus[0]&HU16F_ALTHOLDING)
			)setweaponstate("chamber");
			else if(!paf)invoker.weaponstatus[0]&=~HU16F_ALTHOLDING;
		}
		SHTG A 1 A_WeaponReady(WRF_NOFIRE);
		SHTG A 0 A_Refire();
		goto ready;
	fire:
		SHTG A 0 A_JumpIf(invoker.weaponstatus[HU16S_CHAMBER]==2,"shoot");
		SHTG A 1 A_WeaponReady(WRF_NOFIRE);
		SHTG A 0 A_Refire();
		goto ready;
	shoot:
		SHTG A 2;
		SHTG A 1 offset(0,36) A_FireHunter16();
		SHTG E 1 A_WeaponReady(WRF_NOFIRE);
		SHTG E 0{
			if(
				invoker.weaponstatus[HU16S_FIREMODE]>0
				&&invoker.shotpower>HUNTER_MINSHOTPOWER
			)setweaponstate("chamberauto");
		}goto ready;
	altfire:
	chamber:
		SHTG A 0 A_JumpIf(invoker.weaponstatus[0]&HU16F_ALTHOLDING,"nope");
		SHTG A 0 A_SetAltHold(true);
		SHTG A 1 A_StartSound("weapons/huntrackbak",8);
		SHTG AE 1 A_MuzzleClimb(0,frandom(0.6,1.),wepdot:false);
		SHTG E 1 A_JumpIf(pressingaltfire(),"longstroke");
		goto unrack;
	longstroke:
		SHTG F 2 A_MuzzleClimb(frandom(0.1,0.2),wepdot:false);
		SHTG F 0{
			A_Chamber();
			A_MuzzleClimb(-frandom(0.1,0.2),wepdot:false);
		}
	racked:
		SHTG F 1 A_WeaponReady(WRF_NOFIRE);
		SHTG F 0 A_JumpIf(!pressingaltfire(),"unrack");
		SHTG F 0 A_JumpIf(pressingunload(),"rackunload");
		SHTG F 0 A_JumpIf(invoker.weaponstatus[HU16S_CHAMBER],"racked");
		SHTG F 0{
			int rld=0;
			if(pressingreload()){
				rld=1;
				if(invoker.weaponstatus[SH16S_SIDESADDLE]>0)
				invoker.weaponstatus[0]&=~HU16F_FROMPOCKETS;
				else{
					invoker.weaponstatus[0]|=HU16F_FROMPOCKETS;
					rld=2;
				}
			}else if(pressingaltreload()){
				rld=2;
				invoker.weaponstatus[0]|=HU16F_FROMPOCKETS;
			}
			if(
				(rld==2&&countinv("HD16Gauge275InchShellAmmo"))
				||(rld==1&&invoker.weaponstatus[SH16S_SIDESADDLE]>0)
			)setweaponstate("rackreload");
		}
		loop;
	rackreload:
		SHTG F 1 offset(-1,35) A_WeaponBusy(true);
		SHTG F 2 offset(-2,37);
		SHTG F 4 offset(-3,40);
		SHTG F 1 offset(-4,42) A_GrabShells(1,true,true);
		SHTG F 0 A_JumpIf(!(invoker.weaponstatus[0]&HU16F_FROMPOCKETS),"rackloadone");
		SHTG F 6 offset(-5,43);
		SHTG F 6 offset(-4,41) A_StartSound("weapons/pocket",9);
	rackloadone:
		SHTG F 1 offset(-4,42);
		SHTG F 2 offset(-4,41);
		SHTG F 3 offset(-4,40){
			A_StartSound("weapons/huntreloadchamber",8,CHANF_OVERLAP);
			invoker.weaponstatus[HU16S_CHAMBER]=2;
			invoker.handshells16--;
			EmptyHand16(careful:true);
		}
		SHTG F 5 offset(-4,41);
		SHTG F 4 offset(-4,40) A_JumpIf(invoker.handshells16>0,"rackloadone");
		goto rackreloadend;
	rackreloadend:
		SHTG F 1 offset(-3,39);
		SHTG F 1 offset(-2,37);
		SHTG F 1 offset(-1,34);
		SHTG F 0 A_WeaponBusy(false);
		goto racked;

	rackunload:
		SHTG F 1 offset(-1,35) A_WeaponBusy(true);
		SHTG F 2 offset(-2,37);
		SHTG F 4 offset(-3,40);
		SHTG F 1 offset(-4,42);
		SHTG F 2 offset(-4,41);
		SHTG F 3 offset(-4,40){
			int chm=invoker.weaponstatus[HU16S_CHAMBER];
			invoker.weaponstatus[HU16S_CHAMBER]=0;
			if(chm==2){
				invoker.handshells16++;
				EmptyHand16(careful:true);
			}else if(chm==1)A_SpawnItemEx("HD16GaugeSpentShell",
				cos(pitch)*8,0,height-7-sin(pitch)*8,
				vel.x+cos(pitch)*cos(angle-random(86,90))*5,
				vel.y+cos(pitch)*sin(angle-random(86,90))*5,
				vel.z+sin(pitch)*random(4,6),
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
			if(chm)A_StartSound("weapons/huntunloadchamber",8,CHANF_OVERLAP);
		}
		SHTG F 5 offset(-4,41);
		SHTG F 4 offset(-4,40) A_JumpIf(invoker.handshells16>0,"rackloadone");
		goto rackreloadend;

	unrack:
		SHTG F 0 A_StartSound("weapons/huntrackfwd",8);
		SHTG E 1 A_JumpIf(!pressingfire(),1);
		SHTG EA 2{
			if(pressingfire())A_SetTics(1);
			A_MuzzleClimb(0,-frandom(0.6,1.),wepdot:false);
		}
		SHTG A 0 A_ClearRefire();
		goto ready;
	chamberauto:
		SHTG A 1 A_Chamber();
		SHTG A 1 A_JumpIf(invoker.weaponstatus[0]&HU16F_CANFULLAUTO&&invoker.weaponstatus[HU16S_FIREMODE]==2,"ready");
		SHTG A 0 A_Refire();
		goto ready;
	flash:
		SHTF B 1 bright{
			A_Light2();
			HDFlashAlpha(-32);
		}
		TNT1 A 1 A_ZoomRecoil(0.9);
		TNT1 A 0 A_Light0();
		TNT1 A 0 A_AlertMonsters();
		stop;
	altreload:
	reloadfrompockets:
		SHTG A 0{
			if(!countinv("HD16Gauge275InchShellAmmo"))setweaponstate("nope");
			else invoker.weaponstatus[0]|=HU16F_FROMPOCKETS;
		}goto startreload;
	reload:
	reloadfromsidesaddles:
		SHTG A 0{
			int sss=invoker.weaponstatus[SH16S_SIDESADDLE];
			int ppp=countinv("HD16Gauge275InchShellAmmo");
			if(ppp<1&&sss<1)setweaponstate("nope");
				else if(sss<1)
					invoker.weaponstatus[0]|=HU16F_FROMPOCKETS;
				else invoker.weaponstatus[0]&=~HU16F_FROMPOCKETS;
		}goto startreload;
	startreload:
		SHTG A 1{
			if(
				invoker.weaponstatus[HU16S_TUBE]>=invoker.weaponstatus[HU16S_TUBESIZE]
			){
				if(
					invoker.weaponstatus[SH16S_SIDESADDLE]<12
					&&countinv("HD16Gauge275InchShellAmmo")
				)setweaponstate("ReloadSS");
				else setweaponstate("nope");
			}
		}
		SHTG AG 4 A_MuzzleClimb(frandom(.6,.7),-frandom(.6,.7),wepdot:false);
	reloadstarthand:
		SHTG H 1 offset(0,36);
		SHTG H 1 offset(0,38);
		SHTG H 2 offset(0,36);
		SHTG H 2 offset(0,34);
		SHTG H 3 offset(0,36);
		SHTG H 3 offset(0,40) A_CheckPocketSaddles();
		SHTG H 0 A_JumpIf(invoker.weaponstatus[0]&HU16F_FROMPOCKETS,"reloadpocket");
	reloadfast:
		SHTG H 3 offset(0,40) A_GrabShells(3,false);
		SHTG H 3 offset(0,42) A_StartSound("weapons/pocket",9,volume:0.4);
		SHTG H 2 offset(0,41);
		goto reloadashell;
	reloadpocket:
		SHTG H 3 offset(0,39) A_GrabShells(3,false);
		SHTG H 5 offset(0,42) A_StartSound("weapons/pocket",9);
		SHTG H 6 offset(0,41) A_StartSound("weapons/pocket",9);
		SHTG H 4 offset(0,40);
		goto reloadashell;
	reloadashell:
		SHTG H 2 offset(0,36);
		SHTG H 4 offset(0,34)A_LoadTubeFromHand();
		SHTG HHHHHH 1 offset(0,33){
			if(
				PressingReload()
				||PressingAltReload()
				||PressingUnload()
				||PressingFire()
				||PressingAltfire()
				||PressingZoom()
				||PressingFiremode()
			)invoker.weaponstatus[0]|=HU16F_HOLDING;
			else invoker.weaponstatus[0]&=~HU16F_HOLDING;

			if(
				invoker.weaponstatus[HU16S_TUBE]>=invoker.weaponstatus[HU16S_TUBESIZE]
				||(
					invoker.handshells16<1&&(
						invoker.weaponstatus[0]&HU16F_FROMPOCKETS
						||invoker.weaponstatus[SH16S_SIDESADDLE]<1
					)&&
					!countinv("HD16Gauge275InchShellAmmo")
				)
			)setweaponstate("reloadend");
			else if(
				!pressingaltreload()
				&&!pressingreload()
			)setweaponstate("reloadend");
			else if(invoker.handshells16<1)setweaponstate("reloadstarthand");
		}goto reloadashell;
	reloadend:
		SHTG H 4 offset(0,34) A_StartSound("weapons/huntopen",8);
		SHTG H 1 offset(0,36) EmptyHand16(careful:true);
		SHTG H 1 offset(0,34);
		SHTG HGA 3;
		SHTG A 0 A_JumpIf(invoker.weaponstatus[0]&HU16F_HOLDING,"nope");
		goto ready;

	cannibalize:
		SHTG A 2 offset(0,36) A_JumpIf(!countinv("Slayer"),"nope");
		SHTG A 2 offset(0,40) A_StartSound("weapons/pocket",9);
		SHTG A 6 offset(0,42);
		SHTG A 4 offset(0,44);
		SHTG A 6 offset(0,42);
		SHTG A 2 offset (0,36) A_CannibalizeOtherShotgun();
		goto ready;

	unloadSS:
		SHTG A 2 offset(1,34) A_JumpIf(invoker.weaponstatus[SH16S_SIDESADDLE]<1,"nope");
		SHTG A 1 offset(2,34);
		SHTG A 1 offset(3,36);
	unloadSSLoop1:
		SHTG A 4 offset(4,36);
		SHTG A 2 offset(5,37) A_UnloadSideSaddle16();
		SHTG A 3 offset(4,36){	//decide whether to loop
			if(
				PressingReload()
				||PressingFire()
				||PressingAltfire()
				||invoker.weaponstatus[SH16S_SIDESADDLE]<1
			)setweaponstate("unloadSSend");
		}goto unloadSSLoop1;
	unloadSSend:
		SHTG A 3 offset(4,35);
		SHTG A 2 offset(3,35);
		SHTG A 1 offset(2,34);
		SHTG A 1 offset(1,34);
		goto nope;
	unload:
		SHTG A 1{
			if(
				invoker.weaponstatus[SH16S_SIDESADDLE]>0
				&&!(player.cmd.buttons&BT_USE)
			)setweaponstate("unloadSS");
			else if(
				invoker.weaponstatus[HU16S_CHAMBER]<1
				&&invoker.weaponstatus[HU16S_TUBE]<1
			)setweaponstate("nope");
		}
		SHTG BB 4 A_MuzzleClimb(frandom(1.2,2.4),-frandom(1.2,2.4),wepdot:false);
		SHTG C 1 offset(0,34);
		SHTG C 1 offset(0,36) A_StartSound("weapons/huntopen",8);
		SHTG C 1 offset(0,38);
		SHTG D 4 offset(0,36){
			A_MuzzleClimb(-frandom(1.2,2.4),frandom(1.2,2.4),wepdot:false);
			if(invoker.weaponstatus[HU16S_CHAMBER]<1){
				setweaponstate("unloadtube");
			}else A_StartSound("weapons/huntrackbak",8,CHANF_OVERLAP);
		}
		SHTG D 8 offset(0,34){
			A_MuzzleClimb(-frandom(1.2,2.4),frandom(1.2,2.4),wepdot:false);
			int chm=invoker.weaponstatus[HU16S_CHAMBER];
			invoker.weaponstatus[HU16S_CHAMBER]=0;
			if(chm>1){
				A_StartSound("weapons/huntunloadchamber",8,CHANF_OVERLAP);
				if(A_JumpIfInventory("HD16Gauge275InchShellAmmo",0,"null"))A_SpawnItemEx("HD16GaugeFumblingShell",
					cos(pitch)*8,0,height-7-sin(pitch)*8,
					vel.x+cos(pitch)*cos(angle-random(86,90))*5,
					vel.y+cos(pitch)*sin(angle-random(86,90))*5,
					vel.z+sin(pitch)*random(4,6),
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);else{
					HDF.Give(self,"HD16Gauge275InchShellAmmo",1);
					A_StartSound("weapons/pocket",9);
					A_SetTics(5);
				}
			}else if(chm>0)A_SpawnItemEx("HD16GaugeSpentShell",
				cos(pitch)*8,0,height-7-sin(pitch)*8,
				vel.x+cos(pitch)*cos(angle-random(86,90))*5,
				vel.y+cos(pitch)*sin(angle-random(86,90))*5,
				vel.z+sin(pitch)*random(4,6),
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
		}
		SHTG H 0 A_StartSound("weapons/huntrackfwd",8);
		SHTG H 0 A_JumpIf(!pressingunload(),"reloadend");
		SHTG C 4 offset(0,40);
	unloadtube:
		SHTG H 6 offset(0,40) EmptyHand16(careful:true);
	unloadloop:
		SHTG H 8 offset(1,41){
			if(invoker.weaponstatus[HU16S_TUBE]<1)setweaponstate("reloadend");
			else if(invoker.handshells16>=3)setweaponstate("unloadloopend");
			else{
				invoker.handshells16++;
				invoker.weaponstatus[HU16S_TUBE]--;
			}
		}
		SHTG H 4 offset(0,40) A_StartSound("weapons/huntreload",8);
		loop;
	unloadloopend:
		SHTG H 6 offset(1,41);
		SHTG H 3 offset(1,42){
			int rmm=HDPickup.MaxGive(self,"HD16Gauge275InchShellAmmo",ENC_16SHELL234);
			if(rmm>0){
				A_StartSound("weapons/pocket",9);
				A_SetTics(8);
				HDF.Give(self,"HD16Gauge275InchShellAmmo",min(rmm,invoker.handshells16));
				invoker.handshells16=max(invoker.handshells16-rmm,0);
			}
		}
		SHTG H 0 EmptyHand16(careful:true);
		SHTG H 6 A_Jumpif(!pressingunload(),"reloadend");
		goto unloadloop;
	spawn:
		HU16 ABCDEFG -1 nodelay{
			int ssh=invoker.weaponstatus[SH16S_SIDESADDLE];
			if(ssh>=11)frame=0;
			else if(ssh>=9)frame=1;
			else if(ssh>=7)frame=2;
			else if(ssh>=5)frame=3;
			else if(ssh>=3)frame=4;
			else if(ssh>=1)frame=5;
			else frame=6;
		}
	}
	override void InitializeWepStats(bool idfa){
		weaponstatus[HU16S_CHAMBER]=2;
		if(!idfa){
			weaponstatus[HU16S_TUBESIZE]=7;
			weaponstatus[HU16S_CHOKE]=1;
		}
		weaponstatus[HU16S_TUBE]=weaponstatus[HU16S_TUBESIZE];
		weaponstatus[SH16S_SIDESADDLE]=12;
		handshells16=0;
	}
	override void loadoutconfigure(string input){
		int type=getloadoutvar(input,"type",1);
		if(type>=0){
			switch(type){
			case 0:
				weaponstatus[0]|=HU16F_EXPORT;
				weaponstatus[0]&=~HU16F_CANFULLAUTO;
				break;
			case 1:
				weaponstatus[0]&=~HU16F_EXPORT;
				weaponstatus[0]&=~HU16F_CANFULLAUTO;
				break;
			case 2:
				weaponstatus[0]&=~HU16F_EXPORT;
				weaponstatus[0]|=HU16F_CANFULLAUTO;
				break;
			default:
				break;
			}
		}
		if(type<0||type>2)type=1;
		int firemode=getloadoutvar(input,"firemode",1);
		if(firemode>=0)weaponstatus[HU16S_FIREMODE]=clamp(firemode,0,type);
		int choke=min(getloadoutvar(input,"choke",1),7);
		if(choke>=0)weaponstatus[HU16S_CHOKE]=choke;

		int tubesize=((weaponstatus[0]&HU16F_EXPORT)?5:7);
		if(weaponstatus[HU16S_TUBE]>tubesize)weaponstatus[HU16S_TUBE]=tubesize;
		weaponstatus[HU16S_TUBESIZE]=tubesize;
	}
}

enum hunter16status{
	HU16F_CANFULLAUTO=1,
	HU16F_JAMMED=2,
	HU16F_UNLOADONLY=4,
	HU16F_FROMPOCKETS=8,
	HU16F_ALTHOLDING=16,
	HU16F_HOLDING=32,
	HU16F_EXPORT=64,

	HU16S_FIREMODE=1,
	HU16S_CHAMBER=2,
	//3 is for side saddles
	HU16S_TUBE=4,
	HU16S_TUBESIZE=5,
	HU16S_HAND=6,
	HU16S_CHOKE=7,
}

class Hunter16Random:IdleDummy{
	states{
	spawn:
		TNT1 A 0 nodelay{
			let ggg=Hunter(spawn("Hunter",pos,ALLOW_REPLACE));
			if(!ggg)return;
			HDF.TransferSpecials(self,ggg,HDF.TS_ALL);

			if(!random(0,7))ggg.weaponstatus[HU16S_CHOKE]=random(0,7);
			if(!random(0,32)){
				ggg.weaponstatus[0]&=~HU16F_EXPORT;
				ggg.weaponstatus[0]|=HU16F_CANFULLAUTO;
			}else if(!random(0,7)){
				ggg.weaponstatus[0]|=HU16F_EXPORT;
				ggg.weaponstatus[0]&=~HU16F_CANFULLAUTO;
			}
			int tubesize=((ggg.weaponstatus[0]&HU16F_EXPORT)?5:7);
			if(ggg.weaponstatus[HU16S_TUBE]>tubesize)ggg.weaponstatus[HU16S_TUBE]=tubesize;
			ggg.weaponstatus[HU16S_TUBESIZE]=tubesize;
		}stop;
	}
}

