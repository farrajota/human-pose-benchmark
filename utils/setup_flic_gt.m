%% process flic keypoints

%% load flic annotations
load('/media/HDD2/Datasets/Human_Pose/FLIC/FLIC/examples.mat')

%% allocate memory for the ground truth data storage
joints = zeros(2,11+1,1016); % last one is the torso length

%% fill storage with the ground truth coordinates
idx = 1;
for i=1:1:5003
    if examples(1,i).istest == 1
        joints_data_gt = examples(1,i).coords;
        joints(:,1,idx) = joints_data_gt(:,1);   % L shoulder
        joints(:,2,idx) = joints_data_gt(:,2);   % L elbow
        joints(:,3,idx) = joints_data_gt(:,3);   % L wrist
        joints(:,4,idx) = joints_data_gt(:,4);   % R shoulder
        joints(:,5,idx) = joints_data_gt(:,5);   % R elbow
        joints(:,6,idx) = joints_data_gt(:,6);   % R wrist
        joints(:,7,idx) = joints_data_gt(:,7);   % L hip
        joints(:,8,idx) = joints_data_gt(:,10);   % R hip

        joints(:,9,idx) = joints_data_gt(:,13);   % L eye
        joints(:,10,idx) = joints_data_gt(:,14);  % R eye
        joints(:,11,idx) = joints_data_gt(:,17);  % nose

        torso = examples(1,i).torsobox;
        joints(:,12,idx) = [torso(3)-torso(1); torso(4)-torso(2)];
        
        idx = idx + 1;
    end
end

%% Save filtered keypoints
save('FLIC-joints-OC.mat', 'joints')