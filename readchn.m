function mcadat = readchn(fname,plotflag)

if(nargin<2)		% if plotflag was not specified, then default to 0
  plotflag = 0;
end

fp = fopen(fname,'r');
mcadat.filename = fname;
mcadat.filetype = fread(fp,1,'int16');
mcadat.mcanum = fread(fp,1,'int16');
mcadat.segment = fread(fp,1,'int16');
mcadat.dtstamp = '                         ';
mcadat.dtstamp(16:17) = fread(fp,2,'uchar');	% sec
mcadat.realtime = fread(fp,1,'int32')/50;
mcadat.livetime = fread(fp,1,'int32')/50;
mcadat.dtstamp(1:2) = fread(fp,2,'uchar');	% date
mcadat.dtstamp(3:5) = fread(fp,3,'uchar');	% month
mcadat.dtstamp(6:8) = fread(fp,3,'uchar');	% year
mcadat.dtstamp(10:11) = fread(fp,2,'uchar');	% hour
mcadat.dtstamp(13:14) = fread(fp,2,'uchar');	% minutes
mcadat.dtstamp(12) = ':';
mcadat.dtstamp(15) = ':';
mcadat.startchan = fread(fp,1,'int16');
mcadat.nchan = fread(fp,1,'int16');
mcadat.count = fread(fp,mcadat.nchan,'int32');	% counts
%filemark = fread(fp,1,'int16');		% file marker
dum = fread(fp,1,'float32');			% dummy data
dum = fread(fp,1,'float32');			% dummy data
mcadat.econv = fread(fp,1,'float32');		% energy conversion factor
buf = fread(fp,500,'uchar');			% read rest of buffer
mcadat.detector = char(buf(256-10:256-10+32)');

% make vector of channels
mcadat.chan = mcadat.startchan:mcadat.startchan+mcadat.nchan-1; 

% make vector of energies
mcadat.energy = mcadat.chan * mcadat.econv;

% plot, if requested

if(plotflag==1)
  clf;
  plot(mcadat.chan,mcadat.count);	% plot counts versus channel
  axis('tight'); ylabel('counts'); xlabel('channel'); grid on;
  title(mcadat.filename);
  zoom on;
end

if(plotflag==2)
  clf;
  plot(mcadat.energy,mcadat.count);   % plot counts versus energy
  axis('tight'); ylabel('counts'); xlabel('energy [KeV]'); grid on;
  title(mcadat.filename);
  zoom on;
end