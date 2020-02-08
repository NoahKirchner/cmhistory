//Let's get some REAL contraband stuff in here. Because come on, getting brigged for LIPSTICK is no fun.

//Illicit drugs~
/obj/item/storage/pill_bottle/happy
	name = "Happy pills"
	desc = "Highly illegal drug. When you want to see the rainbow."
	skilllock = 0

/obj/item/storage/pill_bottle/happy/New()
	..()
	new /obj/item/reagent_container/pill/happy( src )
	new /obj/item/reagent_container/pill/happy( src )
	new /obj/item/reagent_container/pill/happy( src )
	new /obj/item/reagent_container/pill/happy( src )
	new /obj/item/reagent_container/pill/happy( src )
	new /obj/item/reagent_container/pill/happy( src )
	new /obj/item/reagent_container/pill/happy( src )

/obj/item/storage/pill_bottle/zoom
	name = "Zoom pills"
	desc = "Highly illegal drug. Trade brain for speed."
	skilllock = 0

/obj/item/storage/pill_bottle/zoom/New()
	..()
	new /obj/item/reagent_container/pill/zoom( src )
	new /obj/item/reagent_container/pill/zoom( src )
	new /obj/item/reagent_container/pill/zoom( src )
	new /obj/item/reagent_container/pill/zoom( src )
	new /obj/item/reagent_container/pill/zoom( src )
	new /obj/item/reagent_container/pill/zoom( src )
	new /obj/item/reagent_container/pill/zoom( src )

/*
Co-ca-i-na
*/
/obj/item/cocaine
	name = "\improper cocaine"
	desc = "Cocaine, blow, powder, co-ca-in-a."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "cokepile"
	var/split = 0 //For when you turn it into a line.
	var/obj/item/reagent_container/cocaine/I //To store the reference to the internal

/obj/item/cocaine/proc/Split() //Splits the coke into a line.
	name = "\improper line of cocaine"
	desc = "A nice refreshing line of blow."
	icon_state = "cokeline"
	split = 1

/obj/item/cocaine/proc/Gather() //Returns coke to a pile.
	name = "\improper cocaine"
	desc = "Cocaine, blow, powder, co-ca-in-a."	
	icon_state = "cokepile"
	split = 0

/obj/item/cocaine/New()
	I = new /obj/item/reagent_container/cocaine(src) //Spawns coke internal inside coke item

/obj/item/reagent_container/cocaine //Where reagents are stored.
	name = "Coke Internal"
	desc = "You shouldn't see this!"
	New()
		..()
		reagents.add_reagent("cocaine", 5)

/obj/item/cocaine/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/card/id) || istype(W, /obj/item/weapon/combat_knife/) || istype(W, /obj/item/weapon/throwing_knife/) || istype(W,/obj/item/spacecash/)) //Only items able to make lines.
		if(split == 0) //If a pile
			Split() //Become a line
			user.visible_message("[user] forms the pile into a neat line with the [W]", \
			"You carefully turn the pile into a line with the [W]")			
		else //If a line
			Gather() //Become a pile
			user.visible_message("[user] forms the line into a pile with the [W]", \
			"You scoop up the line into a pile with the [W]")		
	else
		user << "<span class = 'warning'>You need to seperate this pile into lines first, use an ID card</span>"

/obj/item/cocaine/attack_hand(mob/user as mob)
	if(split==0) //If a pile
		..() //Pick up like normal
		return
	else //Otherwise you can only snort it, to prevent the turf always being of the person who uses it.
		var/turf/T = get_turf(src) //Gets turf of the coke
		var/snortloc = T //For empty turfs. Var determines what is snorted off of for flavour
		if(T.contents) //If the tile has anything on it
			for(var/contained in T.contents) //For every item in the turf's contents list
				if(istype(contained, /mob/living/carbon/) || istype(contained, /obj/structure/table/)) //Allows you to snort off of mobs & tables
					snortloc = contained //If a mob or table is on the tile the coke is on, that becomes what is snorted off of

		user.visible_message("[user] just railed a line of coke off of [snortloc], holy shit!", \
		"You rail a line of coke off of [snortloc]! Holy shit!")
		playsound(usr.loc, 'sound/effects/sniff1.ogg', 5, 1)//SNIFF EYUP
		I.reagents.trans_to(usr, 5)//Transfers reagents from the container stored inside the coke object to the usr
		I.reagents.reaction(usr, INGEST)
		Dispose()//Delete coke item
		I.Dispose()//Delete internal coke

/obj/item/cocaine/Dispose()
	. = ..()

/obj/item/reagent_container/cocaine/Dispose()
	. = ..()
	


