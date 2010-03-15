#!/usr/bin/env jruby
# Name: Hemanth. B
# Website: java-swing-tutorial.html
# 
# Topic: A basic Java Swing Calculator
# 
# Conventions Used in Source code
# ---------------------------------
#   1. All JLabel components start with jlb*
#   2. All JPanel components start with jpl*
#   3. All JMenu components start with jmenu*
#   4. All JMenuItem components start with jmenuItem*
#   5. All JDialog components start with jdlg*
#   6. All JButton components start with jbn*
#
# Converted to JRuby by Fabio Akita 
include Java

java_import java.awt.BorderLayout
java_import java.awt.Color
java_import java.awt.Container
java_import java.awt.FlowLayout
java_import java.awt.Font
java_import java.awt.GridLayout
java_import java.awt.Window
java_import java.awt.event.ActionEvent
java_import java.awt.event.ActionListener
java_import java.awt.event.KeyEvent
java_import java.awt.event.WindowAdapter
java_import java.awt.event.WindowEvent

java_import javax.swing.JButton
java_import javax.swing.JDialog
java_import javax.swing.JFrame
java_import javax.swing.JLabel
java_import javax.swing.JMenu
java_import javax.swing.JMenuBar
java_import javax.swing.JMenuItem
java_import javax.swing.JPanel
java_import javax.swing.JTextArea
java_import javax.swing.KeyStroke

# convenience method to group similar operations together
class Object
  def with
    yield(self) if block_given?
    self
  end
end

class Calculator < JFrame
  include ActionListener
  
  MAX_INPUT_LENGTH = 20
	INPUT_MODE       = 0
	RESULT_MODE      = 1
	ERROR_MODE       = 2
	
	attr_accessor :display_mode
	attr_accessor :clear_on_next_digit, :percent
	attr_accessor :last_number
	attr_accessor :last_operator
	
	def initialize
	  super
	  # Set Up the JMenuBar.
	  # Have Provided All JMenu's with Mnemonics
	  # Have Provided some JMenuItem components with Keyboard Accelerators
		
	  @f12 = Font.new("SansSerif", 0, 12)
  	@f121 = Font.new("SansSerif", 1, 12)

    @jmenuitem_exit = JMenuItem.new("Exit").with do |m|
      m.font = @f12
      m.accelerator = KeyStroke.getKeyStroke(KeyEvent::VK_X, ActionEvent::CTRL_MASK)
      m.add_action_listener(self)
    end
  	
  	@jmenu_file = JMenu.new("File").with do |m|
      m.font = @f121
      m.mnemonic = KeyEvent::VK_F
      m.add(@jmenuitem_exit)
    end

    @jmenuitem_about = JMenuItem.new("About Calculator").with do |m|
      m.font = @f12
      m.add_action_listener(self)
    end
    
    @jmenu_help = JMenu.new("Help").with do |m|
      m.font = @f121
      m.mnemonic = KeyEvent::VK_H
      m.add(@jmenuitem_about)
    end
    
    mb = JMenuBar.new.with do |m|
      m.add(@jmenu_file)
      m.add(@jmenu_help)
    end
    setJMenuBar(mb)
    
    # Set frame layout manager
    background = Color::gray
    
    @jpl_master = JPanel.new
    
    @jlb_output = JLabel.new("0").with do |l|
      l.horizontal_text_position = JLabel::RIGHT
      l.background = Color::WHITE
      l.opaque = true
    end
    
    # Add components to frame
    content_pane.add(@jlb_output, BorderLayout::NORTH)
    
    @jbn_buttons = 23.times.map { |i| JButton.new }
    
    jpl_buttons = JPanel.new		# container for Jbuttons
    
    # Create numeric Jbuttons
    # set each Jbutton label to the value of index
    10.times do |i| 
      @jbn_buttons[i] = JButton.new(i.to_s)
    end
    
    # Create operator Jbuttons
    %w(+/- . = / * - + sqrt 1/x % Backspace CE C).each_with_index do |op, i|
      @jbn_buttons[i + 10] = JButton.new(op)
    end

    @jbn_buttons.each_with_index do |btn, i|
      btn.font = @f12
      # Setting all Numbered JButton's to Blue. The rest to Red
  		btn.foreground = i < 10 ? Color::blue : Color.red
    end

    @jpl_back_space = JPanel.new.with do |p| 
      p.layout = GridLayout.new(1, 1, 2, 2)
      p.add(@jbn_buttons[20])
    end
    
    @jpl_control = JPanel.new.with do |p| 
      p.layout = GridLayout.new(1, 2, 2 ,2)
      p.add(@jbn_buttons[21])
      p.add(@jbn_buttons[22])
    end
    
    # Set panel layout manager for a 4 by 5 grid
    jpl_buttons.layout = GridLayout.new(4, 5, 2, 2)
    
    # Add buttons to keypad panel starting at top left
    # First row
    (7..9).each { |i| jpl_buttons.add(@jbn_buttons[i]) }
    
    # add button / and sqrt
    [13, 17].each { |i| jpl_buttons.add(@jbn_buttons[i]) }
    
    # Second row
    (4..6).each { |i| jpl_buttons.add(@jbn_buttons[i]) }
    
    # add button * and x^2
    [14, 18].each { |i| jpl_buttons.add(@jbn_buttons[i]) }
    
    # Third row
    (1..3).each { |i| jpl_buttons.add(@jbn_buttons[i]) }
    
    # adds button - and %
    [15, 19].each { |i| jpl_buttons.add(@jbn_buttons[i]) }
    
    # Fourth Row
    # add 0, +/-, ., +, and =
    [0, 10, 11, 16, 12].each { |i| jpl_buttons.add(@jbn_buttons[i]) }
    
    @jpl_master.with do |p|
      p.layout = BorderLayout.new
      p.add(@jpl_back_space, BorderLayout::WEST)
      p.add(@jpl_control, BorderLayout::EAST)
      p.add(jpl_buttons, BorderLayout::SOUTH)
    end

    # activate ActionListener
    @jbn_buttons.each { |btn| btn.add_action_listener(self) }
    
    # Add components to frame
    with do |f|
      f.content_pane.add(@jpl_master, BorderLayout::SOUTH)
      f.request_focus
      f.clear_all
		  f.default_close_operation = JFrame::EXIT_ON_CLOSE
		end
	end
	
	# Perform action
	def actionPerformed(e)
		result = 0.0
	   
		case e.source
		when @jmenuitem_about
		  dlgAbout = CustomABOUTDialog.new(self, 
								"About Java Swing Calculator", true)
			dlgAbout.visible = true
		when @jmenuitem_exit
			JavaLang::System.exit(0)
		end

		# Search for the button pressed until end of array or key found
		@jbn_buttons.each_with_index do |btn, i|
			if e.source == btn
				case i
				when 0..9 then add_digit_to_display(i)
				when 10 then process_sign_change	# +/-
				when 11 then add_decimal_point # decimal point
				when 12 then process_equals # =
				when 13 then process_operator("/") # divide
				when 14 then process_operator("*") # *
				when 15 then process_operator("-") # -
				when 16 then process_operator("+") # +
				when 17:	# sqrt
  				if display_mode != ERROR_MODE
  				  begin
  						display_error("Invalid input for function!") if display_string.start_with?("-")
  						result = Math.sqrt(number_in_display)
  						display_result(result)
  					rescue => ex
  						display_error("Invalid input for function!")
  						self.display_mode = ERROR_MODE
  					end
  				end
        when 18: # 1/x
					if display_mode != ERROR_MODE
					  if number_in_display == 0
						  display_error("Cannot divide by zero!")
							self.display_mode = ERROR_MODE
						else
						  display_result(1 / number_in_display)
						end
					end
        when 19: # %
					if display_mode != ERROR_MODE
						begin
							result = number_in_display / 100
							display_result(result)
						rescue => ex
							display_error("Invalid input for function!")
							self.display_mode = ERROR_MODE
						end
					end
        when 20: # backspace
					if display_mode != ERROR_MODE
						self.display_string = display_string[0..-2]
						self.display_string = "0" if display_string.size < 1
          end
        when 21 then clear_existing # CE
				when 22 then clear_all # C
				end
			end
		end
	end
	
  def display_string=(s)
  	@jlb_output.text = s
  end

  def display_string
  	@jlb_output.text
  end

	def add_digit_to_display(digit)
		self.display_string = "" if clear_on_next_digit

    input_string = display_string
		input_string = display_string[1..-1] if display_string.start_with?("0")

		if (input_string != "0" || digit > 0) && input_string.size < MAX_INPUT_LENGTH
			self.display_string = input_string + digit.to_s
		end

		self.display_mode = INPUT_MODE
		self.clear_on_next_digit = false
	end

	def add_decimal_point
		self.display_mode = INPUT_MODE
		self.display_string = "" if clear_on_next_digit

		# If the input string already contains a decimal point, don't
		#  do anything to it.
		self.display_string = display_string + "." if display_string.index(".").nil?
	end

	def process_sign_change
		case display_mode
		when INPUT_MODE
			input = display_string
			if input.size > 0 && input != "0"
				self.display_string = input.start_with?("-") ? input.delete("-") : "-" + input
			end
		when RESULT_MODE
			display_result(-1 * number_in_display) if number_in_display != 0
		end
	end

	def clear_all
		self.display_string = "0"
		self.last_operator = "0"
		self.last_number = 0
		self.display_mode = INPUT_MODE
		self.clear_on_next_digit = true
	end

	def clear_existing
		self.display_string = "0"
		self.clear_on_next_digit = true
		self.display_mode = INPUT_MODE
	end

	def number_in_display
		@jlb_output.text.to_f
	end

	def process_operator(op)
		if display_mode != ERROR_MODE
			if last_operator != "0"
				begin
					result = process_last_operator
					display_result(result)
					self.last_number = result
				rescue DivideByZeroException
				end
			else
				self.last_number = number_in_display
			end

			self.clear_on_next_digit = true
			self.last_operator = op
		end
	end

	def process_equals
		result = 0.0

		if display_mode != ERROR_MODE
			begin			
				result = process_last_operator
				display_result(result)
			rescue DivideByZeroException
				display_error("Cannot divide by zero!")
			end

			self.last_operator = "0"
		end
	end

	def process_last_operator
		result = 0.0
		if last_operator == "/"
			raise DivideByZeroException.new if number_in_display.to_i == 0
			result = last_number / number_in_display
    end

    if %w(* - +).include?(last_operator)
			result = last_number.send(last_operator.to_sym, number_in_display) 
		end
		result
	end

	def display_result(result)
		self.display_string      = result.to_s
		self.last_number         = result
		self.display_mode        = RESULT_MODE
		self.clear_on_next_digit = true
	end

	def display_error(error_message)
		self.display_string      = error_message
		self.last_number         = 0
		self.display_mode        = ERROR_MODE
		self.clear_on_next_digit = true
	end

end

class DivideByZeroException < Exception; end

class CustomABOUTDialog < JDialog
  include ActionListener
	attr_accessor :jbn_ok

	def initialize(parent, title, modal = true)
		super(parent, title, modal)
		
		jt_area_about = JTextArea.new(5, 21).with do |a|
  		a.text = "Calculator Information\n\nDeveloper:	Hemanth\nVersion:	1.0"
  		a.font = Font.new("SansSerif", 1, 13)
  		a.editable = false		  
		end

		self.jbn_ok = JButton.new(" OK ")
		jbn_ok.add_action_listener(self)

		p1 = JPanel.new(FlowLayout.new(FlowLayout::CENTER)).with do |p|
  		p.add(jt_area_about)
  		p.background = Color::red		  
		end

		p2 = JPanel.new(FlowLayout.new(FlowLayout::CENTER))
		p2.add(jbn_ok)

    with do |f|
  		f.background = Color::black
  		f.content_pane.add(p1, BorderLayout::CENTER)
  		f.content_pane.add(p2, BorderLayout::SOUTH)
  		f.set_location(408, 270)
  		f.resizable = false
  		f.add_window_listener Class.new(WindowAdapter).class_eval {
  		  def windowClosing(e)
  		    aboutDialog = e.window
    			aboutDialog.dispose
  		  end
  		}
      f.pack
    end
	end

	def actionPerformed(e)
		dispose if e.source == jbn_ok
	end
end

if $0 == __FILE__
  calci = Calculator.new.with do |c|
    c.title = "JRuby Swing Calculator"
    c.set_size(241, 217)
    c.pack
    c.set_location(400, 250)
    c.visible = true
    c.resizable = false    
  end
  contentPane = calci.content_pane
  # contentPane.setLayout(new BorderLayout())
end