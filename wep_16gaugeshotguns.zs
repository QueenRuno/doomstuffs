// ------------------------------------------------------------
// 16 Gauge Shotgun (Uncommon)
// ------------------------------------------------------------
class HD16GaugeShotgun:HDWeapon{
	default{
		scale 0.6;
		inventory.pickupmessage "You got a shotgun!";
		obituary "%o got %h the hot bullets of %k's shotgun to die.";

		hdweapon.ammo1 "HD16Gauge275InchShellAmmo",4;
	}
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}
	int handshells16;
	action void EmptyHand16(int amt=-1,bool careful=false){
		if(!amt)return;
		if(amt>0)invoker.handshells16=amt;
		while(invoker.handshells16>0){
			if(careful&&!A_JumpIfInventory("HD16Gauge275InchShellAmmo",0,"null")){
				invoker.handshells16--;
				HDF.Give(self,"HD16Gauge275InchShellAmmo",1);
 			}else if(invoker.handshells16>=4){
				invoker.handshells16-=4;
				A_SpawnItemEx("ShellPickup16Gauge",
					cos(pitch)*1,1,height-7-sin(pitch)*1,
					cos(pitch)*cos(angle)*frandom(1,2)+vel.x,
					cos(pitch)*sin(angle)*frandom(1,2)+vel.y,
					-sin(pitch)+vel.z,
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);
			}else{
				invoker.handshells16--;
				A_SpawnItemEx("HD16GaugeFumblingShell",
					cos(pitch)*5,1,height-7-sin(pitch)*5,
					cos(pitch)*cos(angle)*frandom(1,4)+vel.x,
					cos(pitch)*sin(angle)*frandom(1,4)+vel.y,
					-sin(pitch)*random(1,4)+vel.z,
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);
			}
		}
	}
	action void A_UnloadSideSaddle16(){
		int uamt=clamp(invoker.weaponstatus[SH16S_SIDESADDLE],0,4);
		if(!uamt)return;
		invoker.weaponstatus[SH16S_SIDESADDLE]-=uamt;
		int maxpocket=min(uamt,HDPickup.MaxGive(self,"HD16Gauge275InchShellAmmo",ENC_SHELL));
		if(maxpocket>0&&pressingunload()){
			A_SetTics(16);
			uamt-=maxpocket;
			A_GiveInventory("HD16Gauge275InchShellAmmo",maxpocket);
		}
		A_StartSound("weapons/pocket",9);
		EmptyHand16(uamt);
	}
	action void A_CannibalizeOtherShotgun(){
		let hhh=hdweapon(findinventory(invoker is "Hunter16"?"Slayer":"Hunter16"));
		if(hhh){
			int totake=min(
				hhh.weaponstatus[SH16S_SIDESADDLE],
				HDPickup.MaxGive(self,"HD16Gauge275InchShellAmmo",ENC_SHELL),
				4
			);
			if(totake>0){
				hhh.weaponstatus[SH16S_SIDESADDLE]-=totake;
				A_GiveInventory("HD16Gauge275InchShellAmmo",totake);
			}
		}
	}
	//not all loads are equal
	double shotpower;
	static double getshotpower(){return frandom(0.9,1.05);}
	override void DetachFromOwner(){
		if(handshells16>0){
			if(owner)owner.A_DropItem("HD16Gauge275InchShellAmmo",handshells16);
			else A_DropItem("HD16Gauge275InchShellAmmo",handshells16);
		}
		handshells16=0;
		super.detachfromowner();
	}
	override void failedpickupunload(){
		int sss=weaponstatus[SH16S_SIDESADDLE];
		if(sss<1)return;
		A_StartSound("weapons/pocket",9);
		int dropamt=min(sss,4);
		A_DropItem("HD16Gauge275InchShellAmmo",dropamt);
		weaponstatus[SH16S_SIDESADDLE]-=dropamt;
		setstatelabel("spawn");
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			owner.A_DropInventory("HD16Gauge275InchShellAmmo",amt*4);
		}
	}
	override void ForceBasicAmmo(){
		owner.A_SetInventory("HD16Gauge275InchShellAmmo",3);
	}
	clearscope string getpickupframe(bool usespare){
		int ssh=GetSpareWeaponValue(SH16S_SIDESADDLE,usespare);
		if(ssh>=11)return "A";
		if(ssh>=9)return "B";
		if(ssh>=7)return "C";
		if(ssh>=5)return "D";
		if(ssh>=3)return "E";
		if(ssh>=1)return "F";
		return "G";
	}


}

enum hdshottystatus16{
	SH16S_SIDESADDLE=3,
};
