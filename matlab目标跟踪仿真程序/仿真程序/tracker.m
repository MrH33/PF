clear;
clc;


%���ݵĳ�ʼ��
%��HSV�ռ��У���������ɫ�����ϳ�Ϊһά��������ʱ��һά�����Ĵ�С
v_count=193;
N=500;
%�������ӵĸ���
n=20;%179;%400;%52;
%��Ƶ�����е�ͼ��֡��
first=1;
%��һ֡ͼ����������
% new_sita=0.20;
new_sita=0.10;
%��new_sita��^2��ʾ��ɫ��Ϣ�ĸ�˹�ֲ����
vx=[0,0,0];
vy=[0,0,0];
%�ó�Ŀ����ƶ��ٶ�
runtime=0;%��ȡĿ���ٶȵ�ʱ����
struct_index=0;%�洢�ṹ���ָ��
%����������ӵķ���
sigma_x=3.5;
sigma_y=3.5;
% sigma_x=15;
% sigma_y=15;
%��ǰ10֡ͼ����Ŀ��ģ������ƶ�
pre_probability=zeros(1,10);
%�ж��Ƿ�������ز���
resample_judge=0;

%�õ�Ŀ��ģ��ĳ�ʼ����
I=imread('C:\Users\10125\Desktop\���������˲�����ƵĿ������㷨matlabԴ����\matlabĿ����ٷ������\����ͼƬ1\1.bmp');
% b=I(:,:,1);
[h,s,v] = rgb2hsv(I);
imshow(I);
x1 = 1.2238e+03; 
x2 = 1.2553e+03;
y1 = 439.25;
y2 = 464.75;
% x1 = 1.76525e+03; 
% x2 = 1.82225e+03;
% y1 = 9.065e+02;
% y2 = 9.665e+02;
% rect = getrect();
% x1 = rect(1); 
% x2 = rect(1) + rect(3);
% y1 = rect(2);
% y2 = rect(2) + rect(4);
% x1 = 1.7833e+03; 
% x2 = 1.7938e+03;
% y1 = 925.25;
% y2 = 941.75;

%�õ���ʼ����Ŀ������������
 x=round((x1+x2)/2);
 y=round((y1+y2)/2);
%�õ�����Ŀ����������Բ�ĳ��̰����ƽ��
hx=((x2-x1)/3)^2;
hy=((y2-y1)/3)^2;
sizeimage=size(I);
image_boundary_x=int16(sizeimage(2));
image_boundary_y=int16(sizeimage(1));

%����һ֡����ѡ�񱻸���Ŀ���ͼƬ����ָ�����ļ�����
F = getframe;
mkdir('C:\Users\10125\Desktop\���������˲�����ƵĿ������㷨matlabԴ����\matlabĿ����ٷ������\�������\result');
image_source=strcat('C:\Users\10125\Desktop\���������˲�����ƵĿ������㷨matlabԴ����\matlabĿ����ٷ������\�������\result\','1.bmp');
imwrite(F.cdata,image_source);
% [h,s,v] = rgb2hsv(I);
%�ڵ�һ֡���ֶ�ѡ����Ŀ����г�ʼ������
[H S V]=rgb_to_rank(I);
[Sample_Set,Sample_probability,Estimate,target_histgram]=initialize(x,y,hx,hy,H,S,V,N,image_boundary_x,image_boundary_y,v_count,new_sita);
pre_probability(1)=Estimate(1).probability;


%�ӵڶ�֡����ѭ�������Ľ�����ȥ
for loop=2:n
    struct_index=struct_index+1;
    a=num2str(loop+first-1);
    b=[a,'.bmp'];
    b=['C:\Users\10125\Desktop\���������˲�����ƵĿ������㷨matlabԴ����\matlabĿ����ٷ������\����ͼƬ1\',b];
    I=imread(b);
    [H,S,V]=rgb_to_rank(I);
    %�����������
    [Sample_Set,after_prop]=reproduce(Sample_Set,vx,vy,image_boundary_x,image_boundary_y,I,N,sigma_x,sigma_y,runtime);
    
    %�ó�������Ŀ����ڵ�ǰ֡��Ԥ��λ��
    [Sample_probability,Estimate,vx,vy,TargetPic,Sample_histgram]=evaluate(Sample_Set,Estimate,target_histgram,new_sita,loop,after_prop,H,S,V,N,image_boundary_x,image_boundary_y,v_count,vx,vy,hx,hy,Sample_probability);
    %ģ�����ʱ���ز����ж�ʱ����Ҫ�õ���һ����ȨֵSample_probability
    
    %ģ�����
    if(loop<=10)%ǰ10֡���������������Ҫ������д���
        sum_probability=0;
        for p=1:loop-1
            sum_probability=sum_probability+pre_probability(p);
        end 
        mean_probability=sum_probability/(loop-1);
    else%ֱ����ȡ��ֵ
        mean_probability=mean(pre_probability);
    end
    mean_probability;
    Estimate(loop).probability;
    if(Estimate(loop).probability>mean_probability)
    [target_histgram,pre_probability]=update_target(target_histgram,Sample_histgram,Sample_probability,pre_probability,Estimate,N,v_count,loop,resample_judge);
   %������ģ����£�����Ҫ��pre_probability���и��²���
    else if(loop>10)
        for k=1:9
            pre_probability(k)=pre_probability(k+1);
        end
        pre_probability(10)=Estimate(loop).probability;
        else 
            pre_probability(loop)=Estimate(loop).probability;
        end
    end
    
    
    resample_judge=0;
    
    
    %�ж��Ƿ���Ҫ�ز���
    back_sum_weight=0;
    for judge=1:N
        back_sum_weight=back_sum_weight+(Sample_probability(judge))^2;
    end
    sum_weight=1/back_sum_weight;
    if(sum_weight<N/2)
        %�ز�������
        usetimes=reselect(Sample_Set,Sample_probability,N);
        [Sample_Set,Sample_probability]=assemble(Sample_Set,usetimes,Sample_probability,N);%�����������
        resample_judge=1;
    end
    
    
    %�õ�Ŀ���˶��Ĺ켣
if(struct_index==1)
    routine.x=round(Estimate(loop).x);
    routine.y=round(Estimate(loop).y);
else
    routine(struct_index).x=round(Estimate(loop).x);
    routine(struct_index).y=round(Estimate(loop).y);
end
i=1;
j=1;
while(j<=struct_index)
    for new_x=routine(j).x-i:routine(j).x+i
       for new_y=routine(j).y:routine(j).y+i
            TargetPic(new_y,new_x,1)=250;
            TargetPic(new_y,new_x,2)=250;
            TargetPic(new_y,new_x,3)=55;
       end
    end   
    j=j+1;
end

%����ÿһ֡ͼ���и���Ŀ���Ԥ�����ĵ�
i=1;
for new_x=round(Estimate(loop).x)-i:round(Estimate(loop).x+i)
       for new_y=round(Estimate(loop).y)-i:round(Estimate(loop).y+i)
          TargetPic(new_y,new_x,1)=255;
          TargetPic(new_y,new_x,2)=255;
          TargetPic(new_y,new_x,3)=255;
       end
end

     imshow(TargetPic);
     F = getframe;
     image_source=strcat('C:\Users\10125\Desktop\���������˲�����ƵĿ������㷨matlabԴ����\matlabĿ����ٷ������\�������\result\',num2str(loop),'.bmp');
     imwrite(F.cdata,image_source);  
end


%�ڻҶ�ͼ�л��Ƴ�������Ŀ��Ĺ켣
im_routine=redraw_routine(image_boundary_x,image_boundary_y,routine,struct_index);
figure;
title('������Ŀ����˶��켣ͼ');
hold on;
imshow(im_routine);

