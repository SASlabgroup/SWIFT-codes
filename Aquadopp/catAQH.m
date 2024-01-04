function aqh = catAQH(AQH,varargin)
%Produces summary plot of burst-averaged signature data stored in 'SIG'
%       also returns concatenated data

plotaqh = false;
QCaqh = false;

if nargin > 1
    if any(strcmp(varargin,'plot'))
        plotaqh = true;
    end
    if any(strcmp(varargin,'qc'))
        QCaqh = true;
    end
    if ~(any(strcmp(varargin,'plot') | strcmp(varargin,'qc')))
        error('Optional inputs must be ''plot'' or ''qc''')
    end
end

if isfield(AQH,'time')
    aqh.time = [AQH.time];
    nt = length(aqh.time);
    
    aqh.hrz = AQH(round(end/2)).HRprofile.z;
    nzhr = length(aqh.hrz);
    aqh.hrcorr = NaN(nzhr,nt);
    aqh.hramp = aqh.hrcorr;
    aqh.hrw = aqh.hrcorr;
    aqh.hrwvar = aqh.hrcorr;
    aqh.eps = aqh.hrcorr;
    aqh.mspe = aqh.hrcorr;
    aqh.slope = aqh.hrcorr;
    aqh.pspike = aqh.hrcorr;
    
    aqh.wpeofmag = aqh.hrcorr;
    aqh.eofs = NaN(nzhr,nzhr,nt);
    aqh.eofsvar = aqh.hrcorr;

    for it = 1:length(aqh.time)
        %HR
        nz = length(AQH(it).HRprofile.w);
        aqh.hrcorr(1:nz,it) = AQH(it).HRprofile.QC.hrcorr;
        aqh.hramp(1:nz,it) = AQH(it).HRprofile.QC.hramp;
        aqh.pspike(1:nz,it) = AQH(it).HRprofile.QC.pspike;
        aqh.hrw(1:nz,it) = AQH(it).HRprofile.w;
        aqh.hrwvar(1:nz,it) = AQH(it).HRprofile.wvar;

        aqh.eps(1:nz,it) = AQH(it).HRprofile.QC.epsNF;
        aqh.mspe(1:nz,it) = AQH(it).HRprofile.QC.qualNF.mspe;
        aqh.slope(1:nz,it) = AQH(it).HRprofile.QC.qualNF.slope;
        
        aqh.wpeofmag(1:nz,it) = AQH(it).HRprofile.QC.wpeofmag;
        aqh.eofs(1:nz,1:nz,it) = AQH(it).HRprofile.QC.eofs;
        aqh.eofsvar(1:nz,it) = AQH(it).HRprofile.QC.eofsvar;
    end

    %QC
    badburst = [AQH.badburst];
    if QCaqh && sum(badburst) < length(aqh.time)
        aqh.avgcorr(:,badburst) = [];
        aqh.avgamp(:,badburst) = [];
        aqh.avgu(:,badburst) = [];
        aqh.avgv(:,badburst) = [];
        aqh.avgw(:,badburst) = [];
        aqh.avguvar(:,badburst) = [];
        aqh.avgvvar(:,badburst) = [];
        aqh.avgwvar(:,badburst) = [];
        aqh.hrcorr(:,badburst) = [];
        aqh.hramp(:,badburst) = [];
        aqh.hrw(:,badburst) = [];
        aqh.hrwvar(:,badburst) = [];
        aqh.eps(:,badburst) = [];
        aqh.mspe(:,badburst) = [];
        aqh.slope(:,badburst) = [];  
        aqh.pspike(:,badburst) = [];
        aqh.time(badburst) = [];
        
        aqh.wpeofmag(:,badburst) = [];
        aqh.eofs(:,:,badburst) = [];
        aqh.eofsvar(:,badburst) = [];
    else
        aqh.badburst = badburst;
    end

    % Plot
    if plotaqh && length(aqh.time)>1
        disp('No plotting...')
    end

else
    aqh = [];
    warning('AQH empty...')
end
