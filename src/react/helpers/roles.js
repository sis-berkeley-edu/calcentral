export const hasRoleInList = (role, list) => list.find(name => name === role);

export const activeRoles = (rolesObject) => Object.keys(rolesObject).filter(name => rolesObject[name] ? name : null);
