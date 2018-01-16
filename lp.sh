#!/bin/bash
TEMP=`getopt -o sd: --long show,delete: \
     -n 'example.bash' -- "$@"`

if [ $# == 0 ] ; then echo "\033[31mNo parameter. Use --help...\033[0m" >&2 ; exit 1 ; fi

DEL_ARRAY=()
white="             "
until [ $# -eq 0 ] ; do
        case "$1" in
        		-h|--help)  echo ""
							echo "-s|--show : show apps which have icons in Launchpad";
							echo "-d|--delete : delete icons";
							echo "$white parameter e.g: 10,20,30 "
							echo "$white command like: sh lp.sh -d 10,20,30";
							echo "";
							exit 1;;
                -s|--show)  db=$(sudo find /private/var/folders -name com.apple.dock.launchpad)/db/db
						    echo ""
						    echo "\033[36mFound database to operate on:\033[0m ${db}"
						    echo "\n";
							echo "id|app_title";
				 			echo "";
				 			sqlite3 $db "SELECT item_id,title FROM apps;";
				 			echo "";
				 			shift;;
                -d|--delete)
							db=$(sudo find /private/var/folders -name com.apple.dock.launchpad)/db/db
							echo ""
							echo "\033[36mFound database to operate on:\033[0m ${db}"	

	                        case "$2" in
	                            "") echo "\033[31mdelete parameter error\033[0m"; shift ;;
	                            *)  IFS=',' read -ra del_id <<< "$2"
									echo "\033[36mApp ids you have passed:\033[0m"
									for i in "${del_id[@]}"; do
										app_id=$(sqlite3 $db "SELECT IFNULL((SELECT item_id FROM apps WHERE item_id='$i'),'-1');")
										case $app_id in 
											'-1') echo "\033[31mitem_id: $i not in database\033[0m";;
											*)	app_title=$(sqlite3 $db "SELECT title FROM apps WHERE item_id='$i';");
												DEL_ARRAY+=($app_id);
												echo "\033[32mitem_id: $i $app_title\033[0m";;
											esac
									done	

									if test "${#DEL_ARRAY[*]}" -eq 0
										then echo '\033[31mNO valid app id\033[0m';
											 echo '\033[31mEXIT\033[0m';
										exit 1;
									fi	

									read -p "Are you sure to delete these app icons?[Y/n]:" yn
								    case $yn in
								        [Yy]* ) for i in "${DEL_ARRAY[@]}"; do
												sqlite3 $db "DELETE FROM apps WHERE item_id='$i';"
												done;
												killall Dock;;
								        [Nn]* ) exit;;
								        * ) echo "Please answer yes or no.";;
								    esac
								shift 2 ;;
	                        esac ;;
	                --) shift ; break ;;
					*) echo "\033[31mError parameter. Use --help...\033[0m" ; exit 1 ;;
	        esac
done
