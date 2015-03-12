class InteractionDiagram
  REQUEST_ARROW = '->'
  RESPONSE_ARROW = '-->'
  SOURCE_ON_RIGHT_NOTE_ORIENTATION = 'left'
  SOURCE_ON_LEFT_NOTE_ORIENTATION = 'right'
  BREAK_LINES_PATTERN = /[^\n].{0,100}/

  def initialize(ordered_participants)
    @ordered_participants = ordered_participants
    @lines = @ordered_participants.map { |participant| "participant #{participant}" }
  end

  def write_message(source_name, destination_name, message, isResponse)
    add_participants(source_name, destination_name)
    @lines << "#{source_name}#{isResponse ? RESPONSE_ARROW : REQUEST_ARROW}#{destination_name}: #{break_into_lines(message.gsub(/[\r\n]/,''))}"
  end

  def write_note(source_name, destination_name, note)
    add_participants(source_name, destination_name)
    @lines << "note #{participants_displayed_from_left_to_right(source_name, destination_name) ? SOURCE_ON_LEFT_NOTE_ORIENTATION : SOURCE_ON_RIGHT_NOTE_ORIENTATION} of #{source_name}: #{break_into_lines(note.gsub(/[\r\n]/,'').gsub('#','__HASH__'))}"
  end

  def to_s
    @lines.join("\n")
  end

  private

  def add_participants(source_name, destination_name)
    @ordered_participants << source_name unless @ordered_participants.include? source_name
    @ordered_participants << destination_name unless @ordered_participants.include? destination_name
  end

  def participants_displayed_from_left_to_right(first_participant, second_participant)
    @ordered_participants.find_index(first_participant) < @ordered_participants.find_index(second_participant)
  end

  def break_into_lines(value)
    value.gsub(/\\n/,"\n").scan(BREAK_LINES_PATTERN).join("\n").gsub(/\n/,'\n')
  end
end