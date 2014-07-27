#!/bin/bash
sudo dosfsck -wrlavt #/dev/??? #ntfs는 다른 방법으로 해야함.
#또는 도스창에서 chkdsk /R /X d: << ntfs도 됨.
exit
