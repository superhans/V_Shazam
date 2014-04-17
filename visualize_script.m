
MatlabPath = getenv('LD_LIBRARY_PATH');
setenv('LD_LIBRARY_PATH',getenv('PATH'));

videopath1 = 'More_Serious_Tests/Queries/ST1Query1.mpg';
videopath2 = 'More_Serious_Tests/Database/movie27.mpg';
videopath3 = 'More_Serious_Tests/Database/movie9.mpg';

s1 = visualize(videopath1,2);
s2 = visualize(videopath2,2);
s3 = visualize(videopath3,2);

%% 

size(s1)
size(s2)
size(s3)
match = double((s1>0).*(s2(:,1:size(s1,2))>0));
dnmatch = double((s1>0).*(s3(:,1:size(s1,2))>0));

,figure,k = surf(match);set(k,'edgecolor','none');colormap('gray');view(2);
,figure,l = surf(dnmatch);set(l,'edgecolor','none');colormap('gray');view(2);