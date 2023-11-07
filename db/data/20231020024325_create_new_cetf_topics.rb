class CreateNewCetfTopics < ActiveRecord::Migration[5.2]
  def up
    org = Organization.find_by(subdomain: 'getconnected')

    # Create custom CETF topics with correct translation key
    course_map.each do |topic|
      topic_key = topic[:topic_key]
      data = topic[:data]

      Rails.logger.debug("Topic key: #{topic_key}")
      topic = Topic.find_by(translation_key: topic_key)

      if topic.blank?
        Rails.logger.debug("Creating topic: #{topic_key}")
        topic = Topic.create!(organization: org, translation_key: topic_key, title: data[:topic_title])
      end

      # Assign topic to appropriate courses
      data[:course_titles].each do |title|
        course = org.courses.find_by(title: title)

        if course.blank?
          # Fail if course doesn't exist
          raise MissingCourseError.new("Couldn't find course: #{title}") if Rails.env.production?
          Rails.logger.debug("Skipping course: #{title}")
        else
          Rails.logger.debug("Adding topic #{topic_key} to course: #{title}")
          course.topics << topic unless course.topics.include?(topic)
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  class MissingCourseError < StandardError; end;

  def course_map
    [
      { topic_key: 'education_adult',
        data: { topic_title: 'Education: Adult',
                course_titles: ["Basics of Video Conferencing (New!)",
                                "Microsoft Word",
                                "Cloud Storage",
                                "Conceptos básicos de las videoconferencias (Nuevo)",
                                "Microsoft Word (en Español)",
                                "Almacenamiento en la nube"] }},
      { topic_key: 'job_search',
        data: { topic_title: 'Job Search',
                course_titles: ["Creating Resumes",
                                "Online Job Searching",
                                "Applying for Jobs Online",
                                "Microsoft Word",
                                "Cloud Storage",
                                "Hojas de Vida",
                                "La Búsqueda de Trabajo en línea",
                                "Microsoft Word (en Español)",
                                "Almacenamiento en la nube"] }},
      { topic_key: 'education_child',
        data: { topic_title: 'Education: Child',
                course_titles: ["Basics of Video Conferencing (New!)",
                                "Intro to Email 2: Beyond the Basics",
                                "Microsoft Word",
                                "Conceptos básicos de las videoconferencias (Nuevo)", 
                                "Introducción al correo electrónico 2 (Nuevo)",
                                "Microsoft Word (en Español)"] }},
      { topic_key: 'healthcare',
        data: { topic_title: 'Healthcare',
                course_titles: ["Using MyHealthFinder for Preventive Care",
                                "Using Healthcare.gov to Enroll in Health Insurance"] }},
      { topic_key: 'telehealth',
        data: { topic_title: 'Telehealth',
                course_titles: ["Basics of Video Conferencing (New!)",
                                "Conceptos básicos de las videoconferencias (Nuevo)"] }},
      { topic_key: 'online_shopping',
        data: { topic_title: 'Online Shopping',
                course_titles: ["Buying a Plane Ticket", 
                                "Internet Privacy",
                                "Accounts and Passwords",
                                "Creating a Basic Budget with Excel",
                                "Comprar un boleto de avión",
                                "La Privacidad en Internet",
                                "Crear un presupuesto básico con Excel"] }},
      { topic_key: 'online_billpay',
        data: { topic_title: 'Pay Bills Online',
                course_titles: ["Internet Privacy",
                                "Accounts and Passwords",
                                "Creating a Basic Budget with Excel",
                                "La Privacidad en Internet",
                                "Cuentas y contraseñas",
                                "Crear un presupuesto básico con Excel"] }},
      { topic_key: 'online_banking',
        data: { topic_title: 'Online Banking',
                course_titles: ["Internet Privacy",
                                "Accounts and Passwords",
                                "Creating a Basic Budget with Excel",
                                "La Privacidad en Internet",
                                "Cuentas y contraseñas",
                                "Crear un presupuesto básico con Excel"] }},
      { topic_key: 'online_classes',
        data: { topic_title: 'Online Learning',
                course_titles: ["Basics of Video Conferencing (New!)",
                                "Microsoft Word",
                                "Cloud Storage",
                                "Conceptos básicos de las videoconferencias (Nuevo)",
                                "Microsoft Word (en Español)",
                                "Almacenamiento en la nube"] }},
      { topic_key: 'information_searching',
        data: { topic_title: 'Information Searching',
                course_titles: ["Basic Search", "Introduction to Google Maps",
                                "Intro to Searching Videos on YouTube",
                                "Using MyHealthFinder for Preventive Care",
                                "Using Healthcare.gov to Enroll in Health Insurance",
                                "Búsqueda Básica"] }},
      { topic_key: 'govt',
        data: { topic_title: 'Govt.',
                course_titles: ["Basics of Video Conferencing (New!)",
                                "Conceptos básicos de las videoconferencias (Nuevo)"] }},
      { topic_key: 'communication_social_media',
        data: { topic_title: "Communication & Social Media",
                course_titles: ["Intro to Email",
                                "Intro to Searching Videos on YouTube",
                                "Basics of Video Conferencing (New!)",
                                "Intro to Skype",
                                "Intro to Facebook",
                                "Introducción al correo electrónico",
                                "Conceptos básicos de las videoconferencias (Nuevo)",
                                "Introducción a Skype",
                                "Introducción a Facebook"] }},
      { topic_key: 'software_apps',
        data: { topic_title: "Software & Apps",
                course_titles: ["Intro to Email 2: Beyond the Basics",
                                "Introduction to Google Maps",
                                "Using a PC (Windows 7)",
                                "Microsoft Word", "Cloud Storage",
                                "Basics of Video Conferencing (New!)",
                                "Intro to Skype",
                                "Correo Electrónico 2 Más Haya de lo Básico",
                                "El uso de un PC (Windows 7)",
                                "Microsoft Word (en Español)",
                                "Introducción a Skype",
                                "Almacenamiento en la nube",
                                "Conceptos básicos de las videoconferencias (Nuevo)"] }},
      { topic_key: 'security',
        data: { topic_title: '',
                course_titles: ["Accounts & Passwords (New!)",
                                "Online Fraud and Scams (New!)",
                                "Internet Privacy",
                                "Cuentas y contraseñas",
                                "Fraude y estafas en línea",
                                "La Privacidad en Internet"] }}]
  end
end
