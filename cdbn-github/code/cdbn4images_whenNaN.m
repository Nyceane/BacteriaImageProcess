%This scripts is written to train CDBN model (network parameters), then we
%can use this model to extract features from the train data and test data
%This script is a complement for cdbn4images , sometimes, the calculate of
%probabilities come out NaN, and the program interrupted, but we have store
%the states of last model paramets, and we can conitue with this model
%parameters instead from the early beginning again.

function cdbns=cdbn4images_whenNaN(brokenIterator,modelfile)


%for lables:
%background=-1;
%forground=1;
pars.dataname='traindata';
pars.filtersize=10;
pars.num_filters=36;
pars.pbias=0.5;
pars.pbias_lb=0.01;
pars.pbias_lambda=2;
pars.spacing=2;
pars.learningRate=1e-3;%�������ѧϰ�ʰ���learningRate
pars.l2reg=0.5;%L2_regularization
pars.batch_size=100;%��batchsize��С������һ��{w,b,c}
pars.numepochs=100;
pars.numchannels=1;
pars.initialmomentum  = 0.5;
pars.finalmomentum    = 0.9;

cdbn.crbm{1}.filtersize=4;
cdbn.crbm{2}.filtersize=4;
cdbn.crbm{1}.num_filters=36;
cdbn.crbm{2}.num_filters=100;
cdbn.crbm{1}.numchannels=1;
cdbn.crbm{2}.numchannels=cdbn.crbm{1}.num_filters;
cdbn.crbm{1}.layer=1;%ָ���ô�crbm�������
cdbn.crbm{2}.layer=2;
cdbn.crbm{1}.W = 0.01*randn(cdbn.crbm{1}.filtersize^2, cdbn.crbm{1}.numchannels, cdbn.crbm{1}.num_filters);
cdbn.crbm{2}.W = 0.01*randn(cdbn.crbm{2}.filtersize^2, cdbn.crbm{2}.numchannels, cdbn.crbm{2}.num_filters);
cdbn.crbm{1}.vbias_vec = zeros(cdbn.crbm{1}.numchannels,1);
cdbn.crbm{2}.vbias_vec = zeros(cdbn.crbm{2}.numchannels,1);
cdbn.crbm{1}.hbias_vec = -0.1*ones(cdbn.crbm{1}.num_filters,1);
cdbn.crbm{2}.hbias_vec = -0.1*ones(cdbn.crbm{2}.num_filters,1);
cdbn.crbm{1}.Winc=0;
cdbn.crbm{1}.vbiasinc=0;
cdbn.crbm{1}.hbiasinc=0;
cdbn.crbm{2}.Winc=0;
cdbn.crbm{2}.vbiasinc=0;
cdbn.crbm{2}.hbiasinc=0;

% cdbn.crbm{2}.initialmomentum  = 0.5;
% cdbn.crbm{2}.finalmomentum    = 0.9;
% cdbn.crbm{1}.error_history = [];
% cdbn.crbm{1}.sparsity_history = [];
% cdbn.crbm{2}.error_history = [];
% cdbn.crbm{2}.sparsity_history = [];
%ͨ����������feature maps��ά��(����),���visible layer���Կ�����һ��ͨ����
%�ڶ���input���ǵ�һ���output����������ͨ�������ǵ�һ��crbm������feature maps����˵���ˣ�Ҳ���ǵ�һ��CRBM��numfilters��
cdbn.size=2;%the layers of crbms

fpath='..\patcheswithlabel\data-11-Oct-2014_16163.mat';

load(fpath,'trainFeatureMat');
x=trainFeatureMat;



numofimages=size(x,2);
pars.numofbatches=floor(numofimages/pars.batch_size);

%Ϊ�˷�ֹ��;����Ҫ��������ÿ������һ��ͼƬ������save������ͼƬ�Ľ���洢����
fname_prefix = sprintf('../results/cdbnmodel_%s/crbm_new1h_%s_V1_w%d_b%02d_p%g_pl%g_plambda%g_sp%d_CD_eps%g_l2reg%g_bs%02d_%s',pars.dataname,pars.dataname, pars.filtersize, pars.num_filters, pars.pbias, pars.pbias_lb, pars.pbias_lambda, pars.spacing, pars.learningRate, pars.l2reg, pars.batch_size, datestr(now, 30));
fname_save = sprintf('%s', fname_prefix);

%��weight��visualization�����weight����
fname_prefix1 = sprintf('../results/cdbnfigures_%s/crbm_new1h_%s_V1_w%d_b%02d_p%g_pl%g_plambda%g_sp%d_CD_eps%g_l2reg%g_bs%02d_%s',pars.dataname,pars.dataname, pars.filtersize, pars.num_filters, pars.pbias, pars.pbias_lb, pars.pbias_lambda, pars.spacing, pars.learningRate, pars.l2reg, pars.batch_size, datestr(now, 30));
fname_save1 = sprintf('%s', fname_prefix1);

mkdir(fileparts(fname_save));
mkdir(fileparts(fname_save1));

traindatasize=1000;
traindata=randperm(numofimages,traindatasize);
load('../results/cdbnmodel_traindata/crbm_new1h_traindata_V1_w10_b36_p0.5_pl0.01_plambda2_sp2_CD_eps0.001_l2reg0.5_bs100_20141012T001128_model_0040.mat','cdbn');;
for i=brokenIterator:traindatasize%12557:-1 12558:+1
    xi=x(:,traindata(i));%xi is a 3d patch
    xi=reshape(xi,[16,16,3]);% The size of data is 10*10*3, if it is not this size, just change it.
    xi=rgb2gray(xi);
    cdbn=cdbnmodel(xi,pars,cdbn);%a patch is a minipatch,as the train data is 500, a little small
    %cdbns{i}=cdbn;
    fname_figure  = sprintf('%s_%04d.mat', fname_save1,i);
    %��ʾ����Ȩ�ص�visualization ���
    figure(1), display_network(cdbn.crbm{1}.W);
    saveas(gcf, sprintf('%s_%04d.png', fname_figure,1));%��i��ͼƬ��1���weight
    figure(2),display_network_layer2(cdbn.crbm{2}.W,cdbn.crbm{1}.W);
    saveas(gcf, sprintf('%s_%04d.png', fname_figure,2));%��i��ͼƬ��2���weight
    %���ļ�:cdbn�Ľ��������poshidstates��W��ֵ
    fname_feature_save = sprintf('../results/%s_model_%04d.mat', fname_prefix, i);
    save(fname_feature_save, 'cdbn');%���µ�ǰ��cdbn������ǰ�������Щ��Ƭ�ĵ��������,����ֻ��ѵ��cdbn�׶Σ��������ñ�����������,
    if mod(i,20)
        fname_feature_save = sprintf('%s_%04d.mat', fname_prefix, i);
        save(fname_feature_save, 'cdbn');%���µ�ǰ��cdbn������ǰ�������Щ��Ƭ�ĵ��������,����ֻ��ѵ��cdbn�׶Σ��������ñ�����������,
    end
end
end