function gui07
	% Comment out the next line, then uncomment the lines
	% related to your OS
% 	error('You must edit this file first!');

	% Use this line for Windows
	% Edit 'COM4' to match your port
	% (use serialportlist to list the serial ports visible from Matlab)
	h.port=serialport('COM4',921600);

	% Use this line for Linux
	% Edit '/dev/ttyUSB1' to match your port
	% (use serialportlist to list the serial ports visible from Matlab)
	% (also use "chmod 777 /dev/ttyUSB*" as root to enable access)
%	h.port=serialport('/dev/ttyUSB1',921600);

	% Use this line for Mac OS X
	% Edit '/dev/tty.usbserial-210376B5B9DC1' to match your port
	% (use serialportlist to list the serial ports visible from Matlab)
%	h.port=serialport('/dev/tty.usbserial-210376B5B9DC1',921600);

	% Initialize UIControls
	h.closefig=0;
	h.senddat=0;
	h.fig=figure('Position',[300 300 250 125]);% X Y W H
	set(h.fig,'CloseRequestFcn',@closefig);

	h.out=uicontrol('Style','edit',...
		'String','0',...
		'Units','pixels',...
		'Position',[25 75 75 25],...
		'FontUnits','pixels',...
		'FontSize',20);
	h.send=uicontrol('Style','pushbutton',...
		'String','Send',...
		'Units','pixels',...
		'Position',[125 75 100 25],...
		'FontUnits','pixels',...
		'FontSize',20,...
		'Callback',@sendbut);

	h.in=uicontrol('Style','text',...
		'String','0',...
		'Units','pixels',...
		'Position',[25 25 200 25],...
		'FontUnits','pixels',...
		'FontSize',20);

	% Set units to normalized to make the window extensible
	set(h.out,'Units','normalized');
	set(h.out,'FontUnits','normalized');
	set(h.in,'Units','normalized');
	set(h.in,'FontUnits','normalized');

	% Main loop
	h.error='';
	while true
		% Check for a close figure request
		if (h.closefig==1)
			break;
		end

		% Convert user input
		out=sscanf(get(h.out,'string'),'%d');
		if (isempty(out)==1)
			out=0;
		end
		out=round(out);
		if (out<0)
			out=0;
		end
		if (out>255)
			out=255;
		end
		set(h.out,'String',sprintf('%d',out));

		% Check for a send request
		if (h.senddat==1)
			h.senddat=0;

			% Write one byte to FPGA
			write(h.port,out,'uint8');

			% Read one byte from FPGA
			in=read(h.port,1,'uint8');
			if (length(in)~=1)
				h.error='Timeout reading from FPGA board.';
				break;
			end

			% Convert
			set(h.in,'String',sprintf('%d',in));
		else
			% Pause to prevent CPU saturation
			pause(0.02);
		end

		% Update window
		drawnow;
	end

	% Clean up and exit
	clear h.port;
	delete(h.fig);
	if (~isempty(h.error))
		error(h.error);
	end

	% Callbacks
	function closefig(~,~)
		h.closefig=1;
	end
	function sendbut(~,~,~)
		h.senddat=1;
	end
end
