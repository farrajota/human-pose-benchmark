function sticks = keypoints2sticksFLIC(keypoints)
    sticks = zeros(2,10,size(keypoints,3));    
    sticks(:,1:2,:) = keypoints(:,1:2,:);       % L Upper arm (L shoulder - L elbow)
    sticks(:,3:4,:) = keypoints(:,2:3,:);       % L Lower arm (L elbow - L wrist)
    sticks(:,5:6,:) = keypoints(:,4:5,:);       % R Upper arm (R shoulder - R elbow)
    sticks(:,7:8,:) = keypoints(:,5:6,:);       % R Lower arm (R elbow - R wrist)
    sticks(:,9,:) = mean(keypoints(:,[1 4],:),2);    % torso (L shoulder-R shoudler)
    sticks(:,10,:) = mean(keypoints(:,7:8,:),2);     % hips (L hip - R hip)
end