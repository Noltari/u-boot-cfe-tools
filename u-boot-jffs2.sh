#!/bin/sh

usage() {
	echo "Usage:"
	echo "$(basename $0) -e <erase block> -i <input file> -o <output file>"
}

jffs2_create() {
	local root_dir=$(mktemp -d)

	case "${erase_block}" in
		*k*)
			erase_block=$(echo "$(echo $erase_block | tr -d k) * 1024" | bc -l )
			;;
	esac

	cp $input_file $root_dir

	mkfs.jffs2 \
		--big-endian \
		--pad \
		--no-cleanmarkers \
		--eraseblock=$erase_block \
		--root=$root_dir \
		--output=$output_file \
		--compression-mode=none

	rm -rf $root_dir
}

main() {
	while getopts ":e:hi:o:" opt; do
		case "${opt}" in
			'e')
				erase_block=$OPTARG
				;;
			'h')
				usage
				;;
			'i')
				input_file=$OPTARG
				;;
			'o')
				output_file=$OPTARG
				;;
		esac
	done

	jffs2_create 

	exit 0
}

main $@
