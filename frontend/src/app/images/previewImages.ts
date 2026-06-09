const PREVIEW_IMAGES = [
  '/preview_images/african-american-working-father-using-laptop-while-mother-is-homeschooling-their-children.jpg',
  '/preview_images/african-social-worker-taking-care-senior-woman.jpg',
  '/preview_images/arabic-woman-teaching-senior-man-use-laptop-sitting-desk.jpg',
  '/preview_images/brainstorm-concept-multiethnic-group-working-cafeteria-developing-business-strategy-using-laptop-computer-looking-concentrated.jpg',
  '/preview_images/business-people-laptop-team-confused-with-sad-news-marketing-mistake-social-media-disaster-risk-manager-editor-group-employees-reading-computer-copywriting-error-fail.jpg',
  '/preview_images/businesspeoplebusinessmeetingbusiness-corporate-man.jpg',
  '/preview_images/cheerful-call-center-onboarding-specialist-training-worker.jpg',
  '/preview_images/close-up-smiley-teen-man-with-devices.jpg',
  '/preview_images/colleagues-doing-team-work-project.jpg',
  '/preview_images/college-students-different-ethnicities-cramming-1.jpg',
  '/preview_images/college-students-different-ethnicities-cramming.jpg',
  '/preview_images/concentrated-people-reading-information-from-laptop.jpg',
  '/preview_images/confident-female-manager-showing-presentation-laptop-young-woman-mature-man-speaking-explaining-details.jpg',
  '/preview_images/corporate-workers-brainstorming-together.jpg',
  '/preview_images/creative-collaboration-business-women-computer-night-office-teamwork-planning-design-lady-partnership-designer-team-coworking-online-project-vision-proposal-strategy.jpg',
  '/preview_images/diverse-colleagues-studying-with-computer.jpg',
  '/preview_images/diversity-coworker-smile-office-with-computer-teamwork-collaboration-coworking-colleagues-people-happy-pc-startup-company-business-with-research-online-internet.jpg',
  '/preview_images/elderly-age-couple-using-laptop-while-sitting-sofa-living-room-elderly-woman-taking-sip-coffee.jpg',
  '/preview_images/family-grandfather-kid-with-tablet-happy-with-technology-streaming-online-with-app-love-care-with-man-girl-watching-cartoon-together-happiness-bonding-with-wifi-home.jpg',
  '/preview_images/family-looking-together-laptop-home.jpg',
  '/preview_images/fashionable-african-student-wearing-hat-glasses-sitting-front-open-laptop-with-surprised-look.jpg',
  '/preview_images/focused-senior-guy-reading-academic-text-laptop-university-sitting-vintage-study-room.jpg',
  '/preview_images/friends-using-laptop-while-sitting-home.jpg',
  '/preview_images/friends-working-together-front-view.jpg',
  '/preview_images/front-view-friends-sitting-restaurant.jpg',
  '/preview_images/full-shot-woman-kid-with-tablet.jpg',
  '/preview_images/girl-teaching-her-grandfather-how-use-laptop.jpg',
  '/preview_images/grand-parent-learning-use-digital-divice.jpg',
  '/preview_images/group-adult-women-working-together.jpg',
  '/preview_images/group-senior-friends-using-laptop-together-retirement-home.jpg',
  '/preview_images/group-women-looking-through-laptop.jpg',
  '/preview_images/group-young-people-using-laptop-together-home-sofa-having-snacks.jpg',
  '/preview_images/group-young-people-using-laptop-together-home-sofa.jpg',
  '/preview_images/happy-black-family-watching-something-laptop.jpg',
  '/preview_images/happy-family-enjoys-with-few-various-laptops.jpg',
  '/preview_images/happy-family-looking-laptop-sofa.jpg',
  '/preview_images/happy-multigenration-family-using-laptop-living-room.jpg',
  '/preview_images/high-angle-family-spending-time-home.jpg',
  '/preview_images/medium-shot-colleagues-looking-computer.jpg',
  '/preview_images/medium-shot-friends-playing-videogame-1.jpg',
  '/preview_images/medium-shot-friends-playing-videogame.jpg',
  '/preview_images/medium-shot-latin-friends-hanging-out.jpg',
  '/preview_images/medium-shot-queer-people-work.jpg',
  '/preview_images/medium-shot-smiley-man.jpg',
  '/preview_images/multiracial-seniors-looking-female-friend-using-laptop-while-sitting-sofa-nursing-home-curiosity-wireless-technology-coffee-togetherness-support-assisted-living-retirement-concept.jpg',
  '/preview_images/people-practicing-social-integration-workspace.jpg',
  '/preview_images/people-working-while-respecting-social-distancing-restriction.jpg',
  '/preview_images/portrait-senior-couple-using-tablet-device-home.jpg',
  '/preview_images/portrait-woman-with-cancer-using-her-laptop-home.jpg',
  '/preview_images/roommates-sharing-happy-moments-together.jpg',
  '/preview_images/roommates-spending-time-together.jpg',
  '/preview_images/senior-bearded-father-glasses-sitting.jpg',
  '/preview_images/senior-parent-woman-tablet-living-room-connection-bonding-with-technology-family-home-mature-people-with-young-female-person-happy-togetherness-couch-community.jpg',
  '/preview_images/senior-people-school-class-with-laptop-computer-1.jpg',
  '/preview_images/senior-people-school-class-with-laptop-computer-2.jpg',
  '/preview_images/senior-people-school-class-with-laptop-computer.jpg',
  '/preview_images/side-view-portrait-mature-black-woman-using-computer-school-senior-people-copy-space.jpg',
  '/preview_images/student-teacher-waving-laptop.jpg',
  '/preview_images/stylish-black-lesbian-with-afro-hairstyle-braces-browsing-internet-shopping-online.jpg',
  '/preview_images/tablet-family-excited-child-with-success-winning-clapping-good-exam-results-kid-grandparents-mother-technology-school-achievement-prize-celebrate-with-generations-home.jpg',
  '/preview_images/tablet-family-kid-with-success-home-winning-good-news-exam-results-girl-grandparents-happy-mother-technology-school-achievement-prize-celebration-with-generations.jpg',
  '/preview_images/team-diverse-intellectual-senior-women-reading-text-book-online.jpg',
  '/preview_images/three-people-are-sitting-table-with-laptop.jpg',
  '/preview_images/woman-assisting-men-using-laptop-table-home.jpg',
  '/preview_images/woman-using-laptop-with-her-boyfriend.jpg',
  '/preview_images/women-all-ages-browsing-internet.jpg',
  '/preview_images/women-friends-laptop-bench-city-with-reading-smile-relax-metro-sidewalk-with-social-media-people-students-computer-with-embrace-research-streaming-video-web-street.jpg',
  '/preview_images/workers-working-laptop.jpg',
  '/preview_images/young-creative-team-working-couch.jpg',
  '/preview_images/young-woman-teaching-her-grandfather-how-use-laptop.jpg',
] as const;

function hashString(value: string): number {
  let hash = 0;
  for (let i = 0; i < value.length; i += 1) {
    hash = (hash * 31 + value.charCodeAt(i)) | 0;
  }
  return hash >>> 0; // ensure non-negative
}

export function previewImageForRecord(id?: string | number | null): string {
  if (id == null) {
    return PREVIEW_IMAGES[0];
  }

  const index = hashString(String(id)) % PREVIEW_IMAGES.length;
  return PREVIEW_IMAGES[index];
}
