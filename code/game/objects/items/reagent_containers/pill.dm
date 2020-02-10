////////////////////////////////////////////////////////////////////////////////
/// Pills.
////////////////////////////////////////////////////////////////////////////////

//randomizing pill icons
var/global/list/randomized_pill_icons


/obj/item/reagent_container/pill
	name = "pill"
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = null
	item_state = "pill"
	possible_transfer_amounts = null
	w_class = 1
	volume = 60
	var/pill_desc = "An unknown pill." //the real description of the pill, shown when examined by a medically trained person
	var/crushed = 0
	var/split = null

	New()
		..()
		if(!randomized_pill_icons)
			var/allowed_numbers = list(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21)
			randomized_pill_icons = list()
			for(var/i = 1 to 21)
				randomized_pill_icons += "pill[pick_n_take(allowed_numbers)]"
		if(!icon_state)
			icon_state = "pill[rand(1,21)]"


	examine(mob/user)
		..()
		if(pill_desc)
			display_contents(user)

	attack_self(mob/user as mob)
		return

	attack(mob/M, mob/user, def_zone)

		if(M == user)

			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(H.species.flags & IS_SYNTHETIC)
					H << "\red You can't eat pills."
					return

			M << "\blue You swallow [src]."
			M.drop_inv_item_on_ground(src) //icon update
			if(reagents.total_volume)
				reagents.trans_to_ingest(M, reagents.total_volume)

			cdel(src)
			return 1

		else if(istype(M, /mob/living/carbon/human) )

			var/mob/living/carbon/human/H = M
			if(H.species.flags & IS_SYNTHETIC)
				H << "\red They have a monitor for a head, where do you think you're going to put that?"
				return

			user.visible_message("<span class='warning'>[user] attempts to force [M] to swallow [src].</span>")

			var/ingestion_time = 30
			if(user.mind && user.mind.cm_skills)
				ingestion_time = max(10, 30 - 10*user.mind.cm_skills.medical)

			if(!do_mob(user, M, ingestion_time, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL)) return

			user.drop_inv_item_on_ground(src) //icon update
			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] forces [M] to swallow [src].", 1)

			var/rgt_list_text = get_reagent_list_text()

			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: [rgt_list_text]</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [M.name] by [M.name] ([M.ckey]) Reagents: [rgt_list_text]</font>")
			msg_admin_attack("[user.name] ([user.ckey]) fed [M.name] ([M.ckey]) with [src.name] Reagents: [rgt_list_text] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

			if(reagents.total_volume)
				reagents.trans_to_ingest(M, reagents.total_volume)
				cdel(src)
			else
				cdel(src)

			return 1

		return 0
	

	afterattack(obj/target, mob/user, proximity)
		if(!proximity) return

		if(target.is_open_container() != 0 && target.reagents)
			if(!target.reagents.total_volume)
				user << "\red [target] is empty. Cant dissolve pill."
				return
			user << "\blue You dissolve the pill in [target]"

			var/rgt_list_text = get_reagent_list_text()

			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Spiked \a [target] with a pill. Reagents: [rgt_list_text]</font>")
			msg_admin_attack("[user.name] ([user.ckey]) spiked \a [target] with a pill. Reagents: [rgt_list_text] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

			reagents.trans_to(target, reagents.total_volume)
			for(var/mob/O in viewers(2, user))
				O.show_message("\red [user] puts something in \the [target].", 1)

			spawn(5)
				cdel(src)

		return

/*
Pill crushing & snorting, coca-ina style.
*/

/obj/item/reagent_container/pill/proc/Crush() //Crushes the pill, limits volume to 15u.
	name = "powder"
	desc = "An unknown fine powder."
	icon_state = "cokepile"
	crushed = 1
	split = 0
	volume = 15
	var/negx
	for(var/datum/reagent/X in src.reagents.reagent_list)//For each chemical contained by pill
		negx = 15 - X.volume
		X.volume += negx //Set volume to 15
		X.volume = X.volume/src.reagents.reagent_list.len //Divide by total number of chems in list, to not go above 15


/obj/item/reagent_container/pill/proc/Split() //Splits the pile to allow for use
	name = "line of powder"
	desc = "An unknown fine powder arranged into a line"
	icon_state = "cokeline"
	split = 1

/obj/item/reagent_container/pill/proc/Gather() //Gathers the pile to allow for carrying
	name = "powder"
	desc = "An unknown fine powder."
	icon_state = "cokepile"
	split = 0	

/obj/item/reagent_container/pill/proc/Mix(obj/item/reagent_container/pill/W as obj) //Mixes two powder piles together.
	if(istype(W, /obj/item/reagent_container/pill) && W.crushed) //Making sure that only crushed pills can be mixed
		src.reagents.reagent_list += W.reagents.reagent_list //Combines the reagent lists of both piles
		var/negx 
		for(var/datum/reagent/X in src.reagents.reagent_list) //For each chemical in the pile's reagent list
			negx = 15 - X.volume
			X.volume += negx //Set volume of X to 15
			X.volume = X.volume/src.reagents.reagent_list.len //Divide X by total number of reagents to prevent > 15u total
		W.Dispose() //Deletes one of the piles.
		usr << "<span class = 'notice'> You mix the two powders together in equal parts.</span>"
	else
		usr << "How do you plan to mix those together, exactly?"


/obj/item/reagent_container/pill/attackby(obj/item/W as obj, mob/user as mob) //Handles crushing, dividing and gathering.
	if(crushed == 0) //Making sure it's not a pill
		if(istype(W, /obj/item/weapon/combat_knife) || istype(W, /obj/item/weapon/throwing_knife)) //Sharp objects required to crush the pills.
			Crush()
			user.visible_message("[user] crushes up the pill with [W]", \
			"You crush up the pill with [W]")
			return
		else
			usr << "You're going to need something sharper to crush that pill."
	if(crushed == 1) //Making sure it's a pill
		if(istype(W, /obj/item/card/id) || istype(W, /obj/item/weapon/combat_knife/) || istype(W, /obj/item/weapon/throwing_knife/) || istype(W,/obj/item/spacecash/)) //Only items able of making lines.
			if(split == 0) //If pile
				Split()
				user.visible_message("[user] forms the pile into a neat line with the [W]", \
				"You carefully turn the pile into a line with the [W]")			
			else //If line
				Gather()
				user.visible_message("[user] forms the line into a pile with the [W]", \
				"You scoop up the line into a pile with the [W]")		

		if(istype(W, /obj/item/reagent_container/pill)) //For mixing, proc contains the crushed check
			Mix(W)

	else
		user << "<span class = 'warning'>You need to seperate this pile into lines first, use something sharp.</span>"

/obj/item/reagent_container/pill/attack_hand(mob/user as mob)
	if(crushed == 0) //If just a normal pill, act as normal.
		..()
	else if(split == 0) //If a pile, act as an item slash pill.
		..()
	else //If a line
		var/turf/T = get_turf(src)
		var/snortloc = T
		if(T.contents) //If the turf the coke is on has any other objects on it.
			for(var/contained in T.contents) //For every item in the turf's contents list
				if(istype(contained, /mob/living/carbon/) || istype(contained, /obj/structure/table/)) //Allows you to snort off of mobs & tables
					snortloc = contained //If a mob or table is on the tile the powder is on, that becomes what is snorted off of			
		user.visible_message("[user] just railed [src] off of [snortloc], holy shit!", \
		"You rail [src] off of [snortloc]! Holy shit!")
		playsound(usr.loc, 'sound/effects/sniff1.ogg', 5, 1)//SNIFF EYUP
		src.reagents.trans_to(usr, volume)//Transfers reagents from the container stored inside the powder to the usr
		src.reagents.reaction(usr, INGEST)
		Dispose() //Deletes coke post snort

/obj/item/reagent_container/pill/Dispose()
	. = ..()








////////////////////////////////////////////////////////////////////////////////
/// Pills. END
////////////////////////////////////////////////////////////////////////////////

//Pills
/obj/item/reagent_container/pill/antitox
	pill_desc = "An anti-toxins pill. It neutralizes many common toxins."
	New()
		..()
		icon_state = randomized_pill_icons[1]
		reagents.add_reagent("anti_toxin", 25)

/obj/item/reagent_container/pill/tox
	pill_desc = "A toxins pill. It's highly toxic."
	New()
		..()
		icon_state = randomized_pill_icons[2]
		reagents.add_reagent("toxin", 50)

/obj/item/reagent_container/pill/cyanide
	desc = "A cyanide pill. Don't swallow this!"
	pill_desc = null//so even non medics can see what this pill is.
	New()
		..()
		icon_state = randomized_pill_icons[2]
		reagents.add_reagent("cyanide", 50)

/obj/item/reagent_container/pill/adminordrazine
	pill_desc = "An Adminordrazine pill. It's magic. We don't have to explain it."
	New()
		..()
		icon_state = randomized_pill_icons[3]
		reagents.add_reagent("adminordrazine", 50)

/obj/item/reagent_container/pill/stox
	pill_desc = "A sleeping pill commonly used to treat insomnia."
	New()
		..()
		icon_state = randomized_pill_icons[4]
		reagents.add_reagent("stoxin", 15)

/obj/item/reagent_container/pill/kelotane
	pill_desc = "A Kelotane pill. Used to treat burns."
	New()
		..()
		icon_state = randomized_pill_icons[5]
		reagents.add_reagent("kelotane", 15)

/obj/item/reagent_container/pill/paracetamol
	pill_desc = "A Paracetamol pill. Painkiller for the ages."
	New()
		..()
		icon_state = randomized_pill_icons[6]
		reagents.add_reagent("paracetamol", 15)

/obj/item/reagent_container/pill/tramadol
	pill_desc = "A Tramadol pill. A simple painkiller."
	New()
		..()
		icon_state = randomized_pill_icons[7]
		reagents.add_reagent("tramadol", 15)


/obj/item/reagent_container/pill/methylphenidate
	pill_desc = "A Methylphenidate pill. This improves the ability to concentrate."
	New()
		..()
		icon_state = randomized_pill_icons[8]
		reagents.add_reagent("methylphenidate", 15)

/obj/item/reagent_container/pill/citalopram
	pill_desc = "A Citalopram pill. A mild anti-depressant."
	New()
		..()
		icon_state = randomized_pill_icons[9]
		reagents.add_reagent("citalopram", 15)


/obj/item/reagent_container/pill/inaprovaline
	pill_desc = "An Inaprovaline pill. Used to stabilize patients."
	New()
		..()
		icon_state = randomized_pill_icons[10]
		reagents.add_reagent("inaprovaline", 30)

/obj/item/reagent_container/pill/dexalin
	pill_desc = "A Dexalin pill. Used to treat oxygen deprivation."
	New()
		..()
		icon_state = randomized_pill_icons[11]
		reagents.add_reagent("dexalin", 15)

/obj/item/reagent_container/pill/spaceacillin
	pill_desc = "A Spaceacillin pill. Used to treat infected wounds and slow down viral infections."
	New()
		..()
		icon_state = randomized_pill_icons[12]
		reagents.add_reagent("spaceacillin", 10)

/obj/item/reagent_container/pill/happy
	pill_desc = "A Happy Pill! Happy happy joy joy!"
	New()
		..()
		icon_state = randomized_pill_icons[13]
		reagents.add_reagent("space_drugs", 15)
		reagents.add_reagent("sugar", 15)

/obj/item/reagent_container/pill/zoom
	pill_desc = "A Zoom pill! Gotta go fast!"
	New()
		..()
		icon_state = randomized_pill_icons[14]
		reagents.add_reagent("impedrezene", 10)
		reagents.add_reagent("synaptizine", 5)
		reagents.add_reagent("hyperzine", 5)

/obj/item/reagent_container/pill/russianRed
	pill_desc = "A Russian Red pill. A very dangerous radiation-countering substance."
	New()
		..()
		icon_state = randomized_pill_icons[15]
		reagents.add_reagent("russianred", 10)


/obj/item/reagent_container/pill/peridaxon
	pill_desc = "A Peridaxon pill. Heals internal organ damage."
	New()
		..()
		icon_state = randomized_pill_icons[16]
		reagents.add_reagent("peridaxon", 10)


/obj/item/reagent_container/pill/imidazoline
	pill_desc = "An Imidazoline pill. Heals eye damage."
	New()
		..()
		icon_state = randomized_pill_icons[17]
		reagents.add_reagent("imidazoline", 10)


/obj/item/reagent_container/pill/alkysine
	pill_desc = "An Alkysine pill. Heals brain damage."
	New()
		..()
		icon_state = randomized_pill_icons[18]
		reagents.add_reagent("alkysine", 10)


/obj/item/reagent_container/pill/bicaridine
	pill_desc = "A Bicaridine pill. Heals brute damage."
	New()
		..()
		icon_state = randomized_pill_icons[19]
		reagents.add_reagent("bicaridine", 15)

/obj/item/reagent_container/pill/quickclot
	pill_desc = "A Quickclot pill. Stabilizes internal bleeding temporarily."
	New()
		..()
		icon_state = randomized_pill_icons[20]
		reagents.add_reagent("quickclot", 10)

/obj/item/reagent_container/pill/ultrazine
	//pill_desc = "An Ultrazine pill. A highly-potent, long-lasting combination CNS and muscle stimulant. Extremely addictive."

/obj/item/reagent_container/pill/ultrazine/New()
	..()
	icon_state = randomized_pill_icons[21]
	reagents.add_reagent("ultrazine", 5)

/obj/item/reagent_container/pill/chlorine
	name = "Water purification tablet"
	pill desc = "A chlorine tablet used to purify water."
	New()
		..()
		icon_state = "pill7"
		reagents.add_reagent("chlorine", 2)