/obj/item/stack/rods
	name = "metal rod"
	desc = "Some rods. Can be used for building, or something."
	singular_name = "metal rod"
	icon_state = "rods"
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = 3.0
	force = 9.0
	throwforce = 15.0
	throw_speed = 5
	throw_range = 20
	matter = list("metal" = 1875)
	max_amount = 60
	attack_verb = list("hit", "bludgeoned", "whacked")

/obj/item/stack/rods/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(amount < 4)
			user << "\red You need at least four rods to do this."
			return

		if(WT.remove_fuel(0,user))
			var/obj/item/stack/sheet/metal/new_item = new(usr.loc)
			new_item.add_to_stacks(usr)
			for (var/mob/M in viewers(src))
				M.show_message("\red [src] is shaped into metal by [user.name] with the weldingtool.", 3, "\red You hear welding.", 2)
			var/obj/item/stack/rods/R = src
			src = null
			var/replace = (user.get_inactive_hand()==R)
			R.use(4)
			if (!R && replace)
				user.put_in_hands(new_item)
		return
	..()


/obj/item/stack/rods/attack_self(mob/user as mob)
	src.add_fingerprint(user)

	if(!istype(user.loc,/turf)) return 0

	if(istype(get_area(usr.loc),/area/sulaco/hangar))  //HANGER BUILDING
		usr << "<span class='warning'>DO NOT BUILD IN THE HANGAR. This area is needed for the dropships and personnel. ((If you are building defenses, you may be in violation of 'Building Defenses on the Sulaco' in our <a href='http://colonial-marines.com/viewtopic.php?f=57&t=1363'>Marine-Specific Rules</a>))</span>"
		return

	if (locate(/obj/structure/grille, usr.loc))
		for(var/obj/structure/grille/G in usr.loc)
			if (G.destroyed)
				G.health = 10
				G.density = 1
				G.destroyed = 0
				G.icon_state = "grille"
				use(1)
			else
				return 1

	else if(!in_use)
		if(amount < 4)
			user << "\blue You need at least four rods to do this."
			return
		usr << "\blue Assembling grille..."
		in_use = 1
		if (!do_after(usr, 20))
			in_use = 0
			return
		var/obj/structure/grille/F = new /obj/structure/grille/ ( usr.loc )
		usr << "\blue You assemble a grille"
		in_use = 0
		F.add_fingerprint(usr)
		use(4)
	return
