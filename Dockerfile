FROM centos:centos7 as build


#---------------- Environment Vars  ---------------------\
ARG VID_NAME1
ARG VID_NAME2
ARG VID_NAME3
ENV VIDEO_NAME1=$VID_NAME1
ENV VIDEO_NAME2=$VID_NAME2
ENV VIDEO_NAME3=$VID_NAME3

#--------------------------------------------------------


#---------------- Import Video -------------------------
COPY . /root/.
#-------------------------------------------------------


#----------------- setup ffmpeg and preparing workspace  -----------
RUN yum install -y epel-release
RUN yum -y localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm
RUN yum install -y ffmpeg ffmpeg-devel

RUN cd
RUN mkdir multimediaNetworking
WORKDIR multimediaNetworking
RUN mv /root/*.*  .  #copy video file from machine to container in the workspace

#-------------------------------------------------------------------


#----------------- Installing MP4Box #--------------------------------
RUN yum install -y freetype-devel SDL-devel freeglut-devel
RUN yum install -y gpac
RUN yum install -y gettext tree 
#-------------------------------------------------------------------


#----- Generating video with different Resolution and Qualities ----
RUN ffmpeg -i $VIDEO_NAME1 -vf scale=1280:720 vid_res1_720.mp4
RUN ffmpeg -i $VIDEO_NAME1 -vf scale=854:480 vid_res1_480.mp4
RUN ffmpeg -i $VIDEO_NAME1 -vf scale=426:240 vid_res1_240.mp4
RUN ffmpeg -y -i $VIDEO_NAME1 -qp 25 vid1_qp_25.mp4
RUN ffmpeg -y -i $VIDEO_NAME1 -qp 15 vid1_qp_15.mp4
RUN ffmpeg -y -i $VIDEO_NAME1 -qp 49 vid1_qp_49.mp4

RUN ffmpeg -i $VIDEO_NAME2 -vf scale=1280:720 vid_res2_720.mp4
RUN ffmpeg -i $VIDEO_NAME2 -vf scale=854:480 vid_res2_480.mp4
RUN ffmpeg -i $VIDEO_NAME2 -vf scale=426:240 vid_res2_240.mp4
RUN ffmpeg -y -i $VIDEO_NAME2 -qp 25 vid2_qp_25.mp4
RUN ffmpeg -y -i $VIDEO_NAME2 -qp 15 vid2_qp_15.mp4
RUN ffmpeg -y -i $VIDEO_NAME2 -qp 49 vid2_qp_49.mp4

RUN ffmpeg -i $VIDEO_NAME3 -vf scale=1280:720 vid_res3_720.mp4
RUN ffmpeg -i $VIDEO_NAME3 -vf scale=854:480 vid_res3_480.mp4
RUN ffmpeg -i $VIDEO_NAME3 -vf scale=426:240 vid_res3_240.mp4
RUN ffmpeg -y -i $VIDEO_NAME3 -qp 25 vid3_qp_25.mp4
RUN ffmpeg -y -i $VIDEO_NAME3 -qp 15 vid3_qp_15.mp4
RUN ffmpeg -y -i $VIDEO_NAME3 -qp 49 vid3_qp_49.mp4
#-------------------------------------------------------------------


#---------------------- Generate mpd video  ------------------------
RUN MP4Box -dash 10000 -dash-profile live -out output1 vid1_qp_15.mp4#video vid1_qp_25.mp4#video vid1_qp_49.mp4#video vid1.mp4#video vid_res1_240.mp4#video vid_res1_480.mp4#video vid_res1_720.mp4#video

RUN MP4Box -dash 10000 -dash-profile live -out output2 vid2_qp_15.mp4#video vid2_qp_25.mp4#video vid2_qp_49.mp4#video vid2.mp4#video vid_res2_240.mp4#video vid_res2_480.mp4#video vid_res2_720.mp4#video

RUN MP4Box -dash 10000 -dash-profile live -out output3 vid3_qp_15.mp4#video vid3_qp_25.mp4#video vid3_qp_49.mp4#video vid3.mp4#video vid_res3_240.mp4#video vid_res3_480.mp4#video vid_res3_720.mp4#video
#-------------------------------------------------------------------



#---------------------Copy File to ngnix Server and Rub it -------------------
FROM nginx:latest
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build ./multimediaNetworking/. /usr/share/nginx/html/
RUN ls /usr/share/nginx/html/

EXPOSE 80
EXPOSE 8080


