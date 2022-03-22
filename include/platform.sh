# platform specific variables and functions

# needed 3rd party programs
for bin in pkg_info pkg_tarup pkgin rsync curl
do
	binpath=`which ${bin}`
	if [ -z "${binpath}" ]; then
		echo "${bin} is required for sailor to work"
		exit 1
	fi
	eval ${bin}=${binpath}
done

rsync="${rsync} -av"

p_ldd() {
	/usr/bin/ldd -f'%p\n' ${1}
}
mkdevs() {
	${cp} /dev/MAKEDEV ${shippath}/dev
	cd ${shippath}/dev && sh MAKEDEV std random
	cd -
}
mounts() {
	mcmd=${1}
	for mtype in ro rw
	do
		eval mnt=\$"${mtype}_mounts"
		[ -z "${mnt}" ] && continue
		for mp in ${mnt}
		do
			[ ! -d "${mp}" ] && continue
			${mkdir} ${shippath}/${mp}
			[ ${mcmd} = "mount" ] && \
				${loopmount} -o ${mtype} \
				${mp} ${shippath}/${mp}
			[ ${mcmd} = "umount" ] && \
				${umount} ${shippath}/${mp}
		done
	done
}
iflist() {
	${ifconfig} -l
}
dns() {
	true
}

readlink="$(which readlink) -f"
master_passwd=master.passwd
def_bins="/libexec/ld.elf_so /usr/libexec/ld.elf_so $(which pwd_mkdb)"
loopmount="/sbin/mount -t null"

# binaries needed by many packages and not listed in +INSTALL
# most installation and startup scripts also need /bin/sh
def_bins="${def_bins} ${useradd} ${groupadd} ${pkg_info} ${pkgin} \
	/bin/sh /bin/test $(which nologin) /bin/echo /bin/ps /bin/sleep \
	$(which sysctl) $(which logger) $(which kill) $(which printf) \
	 /bin/sh ${ping}"
