/*
Copyright 2018 New Vector Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

const helpers = require('../helpers');
const assert = require('assert');

module.exports = async function join(page, roomName, acceptTerms = false) {
  //TODO: brittle selector
  const directoryButton = await helpers.waitAndQuerySelector(page, '.mx_RoleButton[aria-label="Room directory"]');
  await directoryButton.click();

  const roomInput = await helpers.waitAndQuerySelector(page, '.mx_DirectorySearchBox_input');
  await helpers.replaceInputText(roomInput, roomName);

  const firstRoomLabel = await helpers.waitAndQuerySelector(page, '.mx_RoomDirectory_table .mx_RoomDirectory_name:first-child');
  await firstRoomLabel.click();

  const joinLink = await helpers.waitAndQuerySelector(page, '.mx_RoomPreviewBar_join_text a');
  await joinLink.click();

  if (acceptTerms) {
    const reviewTermsButton = await helpers.waitAndQuerySelector(page, '.mx_QuestionDialog button.mx_Dialog_primary');
    const termsPagePromise = helpers.waitForNewPage();
    await reviewTermsButton.click();
    const termsPage = await termsPagePromise;
    const acceptButton = await termsPage.$('input[type=submit]');
    await acceptButton.click();
    await helpers.delay(500); //TODO yuck, timers
    //try to join again after accepting the terms

    //TODO need to do this because joinLink is detached after switching target
    const joinLink2 = await helpers.waitAndQuerySelector(page, '.mx_RoomPreviewBar_join_text a');
    await joinLink2.click();
  }


  await page.waitForSelector('.mx_MessageComposer');
}