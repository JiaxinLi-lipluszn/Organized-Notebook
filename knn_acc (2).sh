#!/bin/bash
number_checkpoint=$1
frequency=$2
folder=$3
if_unzip=$4
if [ $if_unzip == 0 ]
then
  unzip /content/drive/MyDrive/data.zip -d /content/
  mv /content/data/test /content/data/val
fi
for i in {60..75}
do
  echo $i
  index=$(($i*$frequency))
  echo $index
  if [ $index == 0 ]
  then
    str_idx="0000"
  elif [ $index -lt 10 ]
  then
    str_idx="000"$index
  elif [ $index -lt 100 ]
  then
    str_idx="00"$index
  else
    str_idx="0"$index
  fi
  echo $str_idx
  python3 -m torch.distributed.launch eval_knn_1D.py --pretrained_weights\
   $folder/checkpoint$str_idx.pth --checkpoint_key teacher\
    --data_path /content/data --epoch $index --arch vit_tiny\
    #--dump_features ./features/ --load_features ./features/
  python3 -m torch.distributed.launch eval_knn_1D.py --pretrained_weights\
   $folder/checkpoint$str_idx.pth --checkpoint_key student\
    --data_path /content/data --epoch $index --arch vit_tiny
    #--dump_features ./features/ --load_features ./features/
  echo $str_idx" checkpoint evaluation done."
done
