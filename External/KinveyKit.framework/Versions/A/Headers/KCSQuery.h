//
//  KCSQuery.h
//  KinveyKit
//
//  Copyright (c) 2012-2013 Kinvey. All rights reserved.
//
// This software is licensed to you under the Kinvey terms of service located at
// http://www.kinvey.com/terms-of-use. By downloading, accessing and/or using this
// software, you hereby accept such terms of service  (and any agreement referenced
// therein) and agree that you have read, understand and agree to be bound by such
// terms of service and are of legal age to agree to such terms with Kinvey.
//
// This software contains valuable confidential and proprietary information of
// KINVEY, INC and is subject to applicable licensing agreements.
// Unauthorized reproduction, transmission or distribution of this file and its
// contents is a violation of applicable laws.
//

#import <Foundation/Foundation.h>
#import "KinveyHeaderInfo.h"

typedef enum : NSInteger
{
    // NO OP
    kKCSNOOP = 1,
    
    // Basic operators
    kKCSLessThan = 16,
    kKCSLessThanOrEqual = 17,
    kKCSGreaterThan = 18,
    kKCSGreaterThanOrEqual = 19,
    kKCSNotEqual = 20,
    
    // Geo Queries
    kKCSNearSphere = 1024,
    kKCSWithinBox = 1025,
    kKCSWithinCenterSphere = 1026,
    kKCSWithinPolygon = 1027,
    kKCSNotIn = 1028,
    kKCSIn = 1029,
    kKCSMaxDistance = 1030,
    
    // String Operators
    kKCSRegex = 2000,

    // Joining Operators
    kKCSOr = 4097,
    kKCSAnd = 4098,

    
    // Array Operators
    kKCSAll = 8192,
    kKCSSize = 8193,
   
    // Internal Operators
    kKCSWithin = 17000,
    kKCSMulti = 17001,
    kKCSOptions = 17002,
    kKCSExists = 17003,
    kKCSType = 17004
    
} KCSQueryConditional;

// DO NOT CHANGE THE VALUES IN THIS ENUM.  They're meaningful to the implementation of this class
typedef enum {
    kKCSAscending = 1,
    kKCSDescending = -1
} KCSSortDirection;

/*! Representation of a sorting directive
 
 This object is used to represent a sort key/sort direction, when the query is
 executed, the results will be sorted in the given direction using the given key.
 
 Valid sort directions are:

- `kKCSAscending`: Sort using this key in Ascending order, A > Z, 1 > 9
- `kKCSDescending`: Sort using this key in Descending order, A < Z, 1 < 9
 
 */
@interface KCSQuerySortModifier : NSObject

///---------------------------------------------------------------------------------------
/// @name Properties
///---------------------------------------------------------------------------------------
/*! The field to sort on */
@property (nonatomic, copy) NSString *field;
/*! The direction to sort that field on */
@property (nonatomic, assign) KCSSortDirection direction;

///---------------------------------------------------------------------------------------
/// @name Creating Sort Modifiers
///---------------------------------------------------------------------------------------

/*! Designated initializer, with field and direction
 
 Allows you to quickly build a KCSQuerySortModifier with a direction and
 fieldname.
 
 @param field The field to sort on
 @param direction The direction to sort
 
 @return The created object.
 */
- (instancetype)initWithField: (NSString *)field inDirection: (KCSSortDirection)direction;

@end

/*! Representation of a 'Limit' on a Query
 
 This object represents a limit on a query.  This will limit the number of results
 returned to the integer specified in this limit.
 
 */
@interface KCSQueryLimitModifier : NSObject
/*! The integer to use as a limit */
@property (nonatomic, assign) NSInteger limit;

/*! Initialize Query Limit with integer limit.
 
 Use this function to create your limit
 
 @param limit The limit to apple to a query.
 
 @return The object created.
 
 */
- (instancetype)initWithLimit: (NSInteger)limit;
/*! Obtain a representation suitable for sticking in a query param string
 
 Use this function to obtain a properly escaped URL ready string
 
 @return An escaped string read for a query parameter.
 
 */
- (NSString *)parameterStringRepresentation;

@end

/*! Representation of the Skip parameter in a query
 
 This controls a Skip parameter attached to a query.  Use this
 if you wish to skip the first X number of results.
 
 */
@interface KCSQuerySkipModifier : NSObject
/*! The count of objects to skip. */
@property (nonatomic, assign) NSInteger count;

/*! Initialize an object with a skip count set.
 
 Use this to create a skip modifier with the count set
 
 @param count The count of entities to skip.
 
 @return The newly created object.
 
 */
- (instancetype)initWithcount: (NSInteger)count;
/*! Obtain a representation suitable for sticking in a query param string
 
 Use this function to obtain a properly escaped URL ready string
 
 @return An escaped string read for a query parameter.
 
 */
- (NSString *)parameterStringRepresentation;

@end


/*! A query that can be applied to a Collection.
 
 Kinvey supports a wide range of query operators to limit the data you can retrive from a collection.  This class allows you to build
 complex queries from simple operators.
 
 The supported operators are:
 
- Basic Operators
    - `kKCSLessThan`
    - `kKCSLessThanOrEqual`
    - `kKCSGreaterThan`
    - `kKCSGreaterThanOrEqual`
    - `kKCSNotEqual`
- Geo Queries
    - `kKCSNearSphere`
    - `kKCSWithinBox`
    - `kKCSWithinCenterSphere`
    - `kKCSWithinPolygon`
    - `kKCSMaxDistance` -- NOTE: This can only be used in an AND with `kKCSNearSphere`
 - Set Membership` 
    - `kKCSNotIn`
    - `kKCSIn`
- Joining Operators
    - `kKCSOr`
    - `kKCSAnd`
- Array Operators
    - `kKCSAll`
    - `kKCSSize`
- String Operators
    - `kKCSRegex`
 

 The basic operators allow simple comparisons, Geo Query operators allow geographically relevant queries, set membership
 operators using the familiar in/not-in, Joining operators join multiple queries and Array operators search within arrays.
 
 */
@interface KCSQuery : NSObject

///---------------------------------------------------------------------------------------
/// @name Creating Queries
///---------------------------------------------------------------------------------------
/*! Create a new Simple Query.
 
 This is the simplest query constructor.  This will build a query that matches a single value against a property/field using the given
 conditional.
 
 @param field The field in Kinvey to query on.
 @param conditional The Query Operator (see Overview) that we use to filter.
 @param value The value to search for, must be a supported Kinvey type.
 
 @return The new KCSQuery object (autoreleased).
 
 */
+ (KCSQuery *)queryOnField:(NSString *)field usingConditional:(KCSQueryConditional)conditional forValue: (NSObject *)value;

/*! Create a new exact query.
 
 This builds a query that does an exact match, useful for when you're matching strings or an ID
 NOTE: This route can take a PCRE (Perl Compatible Regular Expression) string and use that as a query,
 this is useful for string matching, such as `@"/brian/i"`, for a case-insensitive match.
 
 @param field The field in Kinvey to query on.
 @param value The value to match, must be a supported Kinvey type.
 
 @return The new KCSQuery object (autoreleased).
 
 */
+ (KCSQuery *)queryOnField:(NSString *)field withExactMatchForValue: (NSObject *)value;

/*! Query a field for multiple values (AND).
 
 This takes multiple query pairs and adds them all to the query, can be called like (assuming `low` and `high` are NSNumbers)
 `KCSQuery *q = [KCSQuery queryOnField:@"age" usingConditionalsForValues:kKCSGreaterThan, low, kKCSLessThan, high, nil];`
 
 @param field The field in Kinvey to query on.
 @param firstConditional The Query Operator (see Overview) that we use to filter
 @param ... A nil terminated list of pairs of conditionals and values.

 @return The new KCSQuery object (autoreleased).
 
 */
+ (KCSQuery *)queryOnField:(NSString *)field usingConditionalsForValues:(KCSQueryConditional)firstConditional, ... NS_REQUIRES_NIL_TERMINATION;

/*! Create a new query joining multiple existing queries.

 Joins each KCSQuery and returns a new Query.  Can either be ANDed or ORed.
 
 @param joiningOperator The operator to join the queries with.
 @param firstQuery The first query to join.
 @param ... A nil terminated list of queriers to join.
 
 @return The new KCSQuery object (autoreleased).
 
 */
+ (KCSQuery *)queryForJoiningOperator:(KCSQueryConditional)joiningOperator onQueries: (KCSQuery *)firstQuery, ... NS_REQUIRES_NIL_TERMINATION;

/*! Create a new query by negating an existing query.
 
 Take an existing query, negate it and make a new query from that.
 `KCSQuery *toBe = [KCSQuery queryOnField:@"to" withExactMatchForValue:@"be"];`
 `KCSQuery *notToBe = [KCSQuery queryNegatingQuery:toBe];`
 `KCSQuery *thatIsTheQuestion = [KCSQuery queryForJoiningOperator:kKCSOr onQueries: toBe, notToBe, nil]`;
 
 @param query The query to negate.
 
 @return The new KCSQuery object (autoreleased).
 
 */
+ (KCSQuery *)queryNegatingQuery:(KCSQuery *)query;

/** Create a query that matches entities where the field is empty or unset.
 
 @param field the backend field to query.
 @return an autoreleased KCSQuery object.
 @since 1.11.0
 @see queryForEmptyOrNullValueInField:
 */
+ (KCSQuery*) queryForEmptyValueInField:(NSString*)field;

/** Create a query that matches entities where the field is empty or unset or has been excplicitly set to `null`.
 
 @param field the backend field to query.
 @return an autoreleased KCSQuery object.
 @since 1.11.0
 @see queryForEmptyValueInField:
 */
+ (KCSQuery*) queryForEmptyOrNullValueInField:(NSString*)field;

/*! Create a new query that matches all entites.
 
 @return The new KCSQuery object (autoreleased).
 */
+ (instancetype)query;


/*! Creates a regular expression query on a field.
 
 This query will return entities where the field values match the regular expression. By default, the match is case-sensitive and new-lines do not match anchors. 
 
 @param field The field in Kinvey to query on.
 @param pattern the regular expression string starting with `^`.
 @return The new KCSQuery object (autoreleased).
 @since 1.8
 @updated 1.23.0
 */
+ (KCSQuery *)queryOnField:(NSString*)field withRegex:(NSString*)pattern;

/*! Copy factory
 
 This creates a new `KCSQuery` with the same values as the old input one. 
 
 @param query the query to copy
 @return a new KCSQuery that matches the old object
 @since 1.14.0
 */
+ (KCSQuery *) queryWithQuery:(KCSQuery*) query;


///---------------------------------------------------------------------------------------
/// @name Modifying Queries
///---------------------------------------------------------------------------------------
/*! ANDs an existing query with the current query set.
 
 This adds another query to the list of queries that must be matched for a property to
 match
 
 @param query The query to add.
 
 */
- (void)addQuery: (KCSQuery *)query;
/*! Add a new Simple Query.
 
 This ANDs a new simple query.  This will add a query that matches a single value against a property/field using the
 given conditional.
 
 @param field The field in Kinvey to query on.
 @param conditional The Query Operator (see Overview) that we use to filter.
 @param value The value to search for, must be a supported Kinvey type.
 
*/
- (void)addQueryOnField:(NSString *)field usingConditional:(KCSQueryConditional)conditional forValue: (NSObject *)value;
/*! Add a new exact query.
 
 This adds (ANDS) a query that does an exact match, useful for when you're matching strings or an ID
 NOTE: This route can take a PCRE (Perl Compatible Regular Expression) string and use that as a query,
 this is useful for string matching, such as `@"/brian/i"`, for a case-insensitive match.
 
 @param field The field in Kinvey to query on.
 @param value The value to match, must be a supported Kinvey type.
 
 */
- (void)addQueryOnField:(NSString *)field withExactMatchForValue: (NSObject *)value; // Accepts Regular Expressions

/*! Add a query a field for multiple values (with AND).
 
 This takes multiple query pairs and adds (with AND) them all to the query, ANDing them with the existing set, and 
 can be called like (assuming `low` and `high` are NSNumbers)
 `KCSQuery *q = [KCSQuery queryOnField:@"age" usingConditionalsForValues:kKCSGreaterThan, low, kKCSLessThan, high, nil];`
 
 @param field The field in Kinvey to query on.
 @param firstConditional The Query Operator (see Overview) that we use to filter
 @param ... A nil terminated list of pairs of conditionals and values.
 
 */
- (void)addQueryOnField:(NSString *)field usingConditionalsForValues:(KCSQueryConditional)firstConditional, ... NS_REQUIRES_NIL_TERMINATION;

/*! Join new queries to the current queries using operator
 
 Joins each KCSQuery with all the queries in the current query set using the given conditional.
 
 @warning As a side effect of this behavior, ALL current queries will be joined using the same conditional
 so if you have 5 queries being ANDed and OR an additional query, you'll now have 6 queries being ORed.  Use
 queryByJoiningQuery: if you don't want this behavior.
 
 @param joiningOperator The operator to join the queries with.
 @param firstQuery The first query to join.
 @param ... A nil terminated list of queriers to join.
 
 @return The new KCSQuery object (autoreleased).
 
 */
- (void)addQueryForJoiningOperator:(KCSQueryConditional)joiningOperator onQueries: (KCSQuery *)firstQuery, ... NS_REQUIRES_NIL_TERMINATION;

/*! Add a new query by negating an existing query.
 
 Take an existing query, negate it and AND it with the current query set.
 
 @param query The query to negate.
 
 @return The new KCSQuery object (autoreleased).
 
 */
- (void)addQueryNegatingQuery:(KCSQuery *)query;

/*! Remove all queries */
- (void)clear;

/*! Take the existing query and negate it */
- (void)negateQuery;

/*! Create a new query by joining an existing query with the current query preserving relationships
 
 This routine joins the existing queries with the new quer using the given operator,
 if you OR the two queries than the existing and relationships are preserved
 
 @param query The query to join
 @param joiningOperator The operator to join the two queries
 
 @return The freshly created query.
 
 */
- (KCSQuery *)queryByJoiningQuery: (KCSQuery *)query usingOperator: (KCSQueryConditional)joiningOperator;


///---------------------------------------------------------------------------------------
/// @name Validating Queries
///---------------------------------------------------------------------------------------
+ (BOOL)validateQuery:(KCSQuery *)query; // API Placeholder
- (BOOL)isValidQuery;                    // API Placeholder

///---------------------------------------------------------------------------------------
/// @name Query Representations
///---------------------------------------------------------------------------------------
/*! The current query represented as a dictionary. */
@property (nonatomic, readonly, copy) NSMutableDictionary *query;

/*! Return the JSON String representation of this query.
 
 @return An NSString containing valid JSON for this query.
 
 */
- (NSString *)JSONStringRepresentation;

/*! Return a byte array of the UTF8 encoded JSON String

 @return A UTF8 encoded chunk of data that contains the JSON string
 
 */
- (NSData *)UTF8JSONStringRepresentation;

/*! Return the representation of the query suitable for using in a query paramter.
 
 @return An NSString ready to be put into a URL Query parameter
 
 */
- (NSString *)parameterStringRepresentation;

/*! Return all of the sort parameters into a string able to be used in a URL query.
 
 @return A String that can be used in a parameter string.
 
 */
- (NSString *)parameterStringForSortKeys;


///---------------------------------------------------------------------------------------
/// @name Modifying Queries
///---------------------------------------------------------------------------------------

/*! The current limit modifier, defaults to nil.  Set to nil to clear the limit modifier. */
@property (nonatomic, strong) KCSQueryLimitModifier *limitModifer;
/*! The current skip modifier, defaults to nil.  Set to nil to clear the skip modifier. */
@property (nonatomic, strong) KCSQuerySkipModifier *skipModifier;
/*! The current list of sort modifiers.  Read only, use addSortModifier: and clearSortModifiers to modify. */
@property (nonatomic, strong, readonly) NSArray *sortModifiers;

/*! Add a new sort modifier to our list of modifiers.
 
 Use the to add more sort modifiers
 
 @param modifier The sort modifier to add to the list.

 */
- (void)addSortModifier:(KCSQuerySortModifier *)modifier;
/*! Clear all sort modifiers
 
 Remove all entries in the list of sort modifiers.
 
 */
- (void)clearSortModifiers;


@end
